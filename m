Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5C7E96B0274
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 09:38:39 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w84so71287593wmg.1
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 06:38:39 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id c184si2463233wme.22.2016.09.22.06.38.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 06:38:37 -0700 (PDT)
Subject: Re: [PATCH 4/4] writeback: introduce super_operations->write_metadata
References: <1474405068-27841-1-git-send-email-jbacik@fb.com>
 <1474405068-27841-5-git-send-email-jbacik@fb.com>
 <20160922114828.GN2834@quack2.suse.cz>
From: Josef Bacik <jbacik@fb.com>
Message-ID: <3dd716eb-dc3e-991c-ac97-a0245890383c@fb.com>
Date: Thu, 22 Sep 2016 09:36:53 -0400
MIME-Version: 1.0
In-Reply-To: <20160922114828.GN2834@quack2.suse.cz>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, jack@suse.com, viro@zeniv.linux.org.uk, dchinner@redhat.com, hch@lst.de, linux-mm@kvack.org, hannes@cmpxchg.org

On 09/22/2016 07:48 AM, Jan Kara wrote:
> On Tue 20-09-16 16:57:48, Josef Bacik wrote:
>> Now that we have metadata counters in the VM, we need to provide a way to kick
>> writeback on dirty metadata.  Introduce super_operations->write_metadata.  This
>> allows file systems to deal with writing back any dirty metadata we need based
>> on the writeback needs of the system.  Since there is no inode to key off of we
>> need a list in the bdi for dirty super blocks to be added.  From there we can
>> find any dirty sb's on the bdi we are currently doing writeback on and call into
>> their ->write_metadata callback.
>>
>> Signed-off-by: Josef Bacik <jbacik@fb.com>
>> ---
>>  fs/fs-writeback.c                | 72 ++++++++++++++++++++++++++++++++++++----
>>  fs/super.c                       |  7 ++++
>>  include/linux/backing-dev-defs.h |  2 ++
>>  include/linux/fs.h               |  4 +++
>>  mm/backing-dev.c                 |  2 ++
>>  5 files changed, 81 insertions(+), 6 deletions(-)
>>
>
> ...
>
>> +	if (!done && sb->s_op->write_metadata) {
>> +		spin_unlock(&wb->list_lock);
>> +		wrote += writeback_sb_metadata(sb, wb, work);
>> +		spin_unlock(&wb->list_lock);
> 		^^^
> 		spin_lock();
>
> Otherwise the patch looks good to me. So feel free to add:
>
> Reviewed-by: Jan Kara <jack@suse.cz>
>
> after fixing the above.
>

Yup I hit this as soon as I started testing so I'll go ahead and add your 
reviewed-by.  I'll resend the whole series after these changes have actually 
gone through some testing since it seems you are happy with the overall 
direction.  Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
