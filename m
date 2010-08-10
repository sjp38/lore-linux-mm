Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 7091A600044
	for <linux-mm@kvack.org>; Mon,  9 Aug 2010 23:06:08 -0400 (EDT)
Received: by vws16 with SMTP id 16so8557270vws.14
        for <linux-mm@kvack.org>; Mon, 09 Aug 2010 20:06:08 -0700 (PDT)
Message-ID: <4C60C236.4000509@vflare.org>
Date: Tue, 10 Aug 2010 08:36:30 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH 01/10] Replace ioctls with sysfs interface
References: <1281374816-904-1-git-send-email-ngupta@vflare.org>	<1281374816-904-2-git-send-email-ngupta@vflare.org> <AANLkTimuPK=1+xNMKfV=G1sSG60+=fa7eA3142JJZZ6p@mail.gmail.com>
In-Reply-To: <AANLkTimuPK=1+xNMKfV=G1sSG60+=fa7eA3142JJZZ6p@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@kernel.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Linux Driver Project <devel@linuxdriverproject.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 08/10/2010 12:04 AM, Pekka Enberg wrote:
> On Mon, Aug 9, 2010 at 8:26 PM, Nitin Gupta <ngupta@vflare.org> wrote:
>> Creates per-device sysfs nodes in /sys/block/zram<id>/
>> Currently following stats are exported:
>>  - disksize
>>  - num_reads
>>  - num_writes
>>  - invalid_io
>>  - zero_pages
>>  - orig_data_size
>>  - compr_data_size
>>  - mem_used_total
>>
<snip>
>>
>> Signed-off-by: Nitin Gupta <ngupta@vflare.org>
> 
> Looks good to me (but I'm not a sysfs guy).
> 
> Acked-by: Pekka Enberg <penberg@kernel.org>
> 

Thanks!

>>  /* Module params (documentation at end) */
>> -static unsigned int num_devices;
>> +unsigned int num_devices;
>> +
>> +static void zram_stat_inc(u32 *v)
>> +{
>> +       *v = *v + 1;
>> +}
>> +
>> +static void zram_stat_dec(u32 *v)
>> +{
>> +       *v = *v - 1;
>> +}
>> +
>> +static void zram_stat64_add(struct zram *zram, u64 *v, u64 inc)
>> +{
>> +       spin_lock(&zram->stat64_lock);
>> +       *v = *v + inc;
>> +       spin_unlock(&zram->stat64_lock);
>> +}
>> +
>> +static void zram_stat64_sub(struct zram *zram, u64 *v, u64 dec)
>> +{
>> +       spin_lock(&zram->stat64_lock);
>> +       *v = *v - dec;
>> +       spin_unlock(&zram->stat64_lock);
>> +}
>> +
>> +static void zram_stat64_inc(struct zram *zram, u64 *v)
>> +{
>> +       zram_stat64_add(zram, v, 1);
>> +}
> 
> These could probably use atomic_inc(), atomic64_inc(), and friends, no?
> 

Yes, I think we could use them. Anyways, they are replaced by percpu stats in
patch 3, so probably this can be left as-is.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
