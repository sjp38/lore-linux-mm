Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 0A52B6B0002
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 06:14:56 -0400 (EDT)
Message-ID: <516BD314.9000302@parallels.com>
Date: Mon, 15 Apr 2013 06:14:44 -0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 14/32] xfs: convert buftarg LRU to generic code
References: <1365429659-22108-1-git-send-email-glommer@parallels.com> <1365429659-22108-15-git-send-email-glommer@parallels.com> <xr9361zo8iav.fsf@gthelen.mtv.corp.google.com>
In-Reply-To: <xr9361zo8iav.fsf@gthelen.mtv.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Dave Shrinnker <david@fromorbit.com>, Serge Hallyn <serge.hallyn@canonical.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Dave Chinner <dchinner@redhat.com>

On 04/15/2013 01:38 AM, Greg Thelen wrote:
> On Mon, Apr 08 2013, Glauber Costa wrote:
>
>> From: Dave Chinner <dchinner@redhat.com>
>>
>> Convert the buftarg LRU to use the new generic LRU list and take
>> advantage of the functionality it supplies to make the buffer cache
>> shrinker node aware.
>>
>> Signed-off-by: Glauber Costa <glommer@parallels.com>
>> Signed-off-by: Dave Chinner <dchinner@redhat.com>
>>
>> Conflicts with 3b19034d4f:
>> 	fs/xfs/xfs_buf.c
>> ---
>>   fs/xfs/xfs_buf.c | 167 +++++++++++++++++++++++++------------------------------
>>   fs/xfs/xfs_buf.h |   5 +-
>>   2 files changed, 79 insertions(+), 93 deletions(-)
>>
>> diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
>> index 8459b5d..4cc6632 100644
>> --- a/fs/xfs/xfs_buf.c
>> +++ b/fs/xfs/xfs_buf.c
>> @@ -85,20 +85,14 @@ xfs_buf_vmap_len(
>>    * The LRU takes a new reference to the buffer so that it will only be freed
>>    * once the shrinker takes the buffer off the LRU.
>>    */
>> -STATIC void
>> +static void
>>   xfs_buf_lru_add(
>>   	struct xfs_buf	*bp)
>>   {
>> -	struct xfs_buftarg *btp = bp->b_target;
>> -
>> -	spin_lock(&btp->bt_lru_lock);
>> -	if (list_empty(&bp->b_lru)) {
>> -		atomic_inc(&bp->b_hold);
>> -		list_add_tail(&bp->b_lru, &btp->bt_lru);
>> -		btp->bt_lru_nr++;
>> +	if (list_lru_add(&bp->b_target->bt_lru, &bp->b_lru)) {
>>   		bp->b_lru_flags &= ~_XBF_LRU_DISPOSE;
>> +		atomic_inc(&bp->b_hold);
>>   	}
>> -	spin_unlock(&btp->bt_lru_lock);
>>   }
>>
>>   /*
>> @@ -107,24 +101,13 @@ xfs_buf_lru_add(
>>    * The unlocked check is safe here because it only occurs when there are not
>>    * b_lru_ref counts left on the inode under the pag->pag_buf_lock. it is there
>>    * to optimise the shrinker removing the buffer from the LRU and calling
>> - * xfs_buf_free(). i.e. it removes an unnecessary round trip on the
>> - * bt_lru_lock.
>> + * xfs_buf_free().
>>    */
>> -STATIC void
>> +static void
>>   xfs_buf_lru_del(
>>   	struct xfs_buf	*bp)
>>   {
>> -	struct xfs_buftarg *btp = bp->b_target;
>> -
>> -	if (list_empty(&bp->b_lru))
>> -		return;
>> -
>> -	spin_lock(&btp->bt_lru_lock);
>> -	if (!list_empty(&bp->b_lru)) {
>> -		list_del_init(&bp->b_lru);
>> -		btp->bt_lru_nr--;
>> -	}
>> -	spin_unlock(&btp->bt_lru_lock);
>> +	list_lru_del(&bp->b_target->bt_lru, &bp->b_lru);
>>   }
>>
>>   /*
>> @@ -151,18 +134,10 @@ xfs_buf_stale(
>>   	bp->b_flags &= ~_XBF_DELWRI_Q;
>>
>>   	atomic_set(&(bp)->b_lru_ref, 0);
>> -	if (!list_empty(&bp->b_lru)) {
>> -		struct xfs_buftarg *btp = bp->b_target;
>> -
>> -		spin_lock(&btp->bt_lru_lock);
>> -		if (!list_empty(&bp->b_lru) &&
>> -		    !(bp->b_lru_flags & _XBF_LRU_DISPOSE)) {
>> -			list_del_init(&bp->b_lru);
>> -			btp->bt_lru_nr--;
>> -			atomic_dec(&bp->b_hold);
>> -		}
>> -		spin_unlock(&btp->bt_lru_lock);
>> -	}
>> +	if (!(bp->b_lru_flags & _XBF_LRU_DISPOSE) &&
>> +	    (list_lru_del(&bp->b_target->bt_lru, &bp->b_lru)))
>> +		atomic_dec(&bp->b_hold);
>> +
>>   	ASSERT(atomic_read(&bp->b_hold) >= 1);
>>   }
>>
>> @@ -1498,83 +1473,95 @@ xfs_buf_iomove(
>>    * returned. These buffers will have an elevated hold count, so wait on those
>>    * while freeing all the buffers only held by the LRU.
>>    */
>> -void
>> -xfs_wait_buftarg(
>> -	struct xfs_buftarg	*btp)
>> +static int
>
> static enum lru_status
>

Uggh, I converted the inode and dcache and forgot to convert xfs. Thanks 
for spotting, Greg!
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
