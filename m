Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id EACAE6B025E
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 16:16:56 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id e7so81321251lfe.0
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 13:16:56 -0700 (PDT)
Received: from mx0b-000ceb01.pphosted.com (mx0b-000ceb01.pphosted.com. [67.231.152.126])
        by mx.google.com with ESMTPS id 80si17633435wmy.26.2016.08.01.13.16.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Aug 2016 13:16:55 -0700 (PDT)
Subject: Re: OOM killer changes
References: <d8f3adcc-3607-1ef6-9ec5-82b2e125eef2@quantum.com>
 <20160801061625.GA11623@dhcp22.suse.cz>
 <b1a39756-a0b5-1900-6575-d6e1f502cb26@Quantum.com>
 <20160801182358.GB31957@dhcp22.suse.cz>
 <30dbabc4-585c-55a5-9f3a-4e243c28356a@Quantum.com>
 <20160801192620.GD31957@dhcp22.suse.cz>
 <939def12-3fa8-e877-ce17-b59db9fa1876@Quantum.com>
 <20160801194323.GE31957@dhcp22.suse.cz>
 <d8116023-dcd4-8763-af77-f2889f84cdb6@Quantum.com>
 <20160801200926.GF31957@dhcp22.suse.cz>
From: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>
Message-ID: <3c022d92-9c96-9022-8496-aa8738fb7358@quantum.com>
Date: Mon, 1 Aug 2016 13:16:49 -0700
MIME-Version: 1.0
In-Reply-To: <20160801200926.GF31957@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>



On 08/01/16 13:09, Michal Hocko wrote:
> On Mon 01-08-16 12:52:40, Ralf-Peter Rohbeck wrote:
>> On 01.08.2016 12:43, Michal Hocko wrote:
>>> On Mon 01-08-16 12:35:51, Ralf-Peter Rohbeck wrote:
>>>> On 01.08.2016 12:26, Michal Hocko wrote:
>>> [...]
>>>>> the amount of dirty pages is much smaller as well as the anonymous
>>>>> memory. The biggest portion seems to be in the page cache. The memory
>>>> The page cache will always be full if I'm writing at full steam to multiple
>>>> drives, no?
>>> Yes, the memory full of page cache is not unusual. The large portion of
>>> that memory being dirty/writeback can be a problem. That is why we have
>>> a dirty memory throttling which slows down (throttles) writers to keep
>>> the amount reasonable. What is your dirty throttling setup?
>>> $ grep . /proc/sys/vm/dirty*
>>>
>>> and what is your storage setup?
>> root@fs:~# grep . /proc/sys/vm/dirty*
>> /proc/sys/vm/dirty_background_bytes:0
>> /proc/sys/vm/dirty_background_ratio:10
>> /proc/sys/vm/dirty_bytes:0
>> /proc/sys/vm/dirty_expire_centisecs:3000
>> /proc/sys/vm/dirty_ratio:20
> With your 8G of RAM this can be quite a lot of dirty data at once. Is
> your storage able to write that back in a reasonable time? I mean this
> shouldn't cause the OOM killer but it can lead to some unexpected stalls
> especially when there are a lot of writers AFAIU. dirty_bytes knob
> should help to define a better cap.
The main filesystems are on the MegaRAID and can do 500-600 MB/s. 
Writing to the USB drives only pushes about 90MB/s per drive.
>
>> /proc/sys/vm/dirtytime_expire_seconds:43200
>> /proc/sys/vm/dirty_writeback_centisecs:500
>>
>>
>> Storage setup:
>>
>> root@fs:~# lsscsi
>> [0:2:0:0]    disk    LSI      MR9271-8iCC      3.29  /dev/sda
>> [0:2:1:0]    disk    LSI      MR9271-8iCC      3.29  /dev/sdb
>> [9:0:0:0]    disk    TOSHIBA  External USB 3.0 5438  /dev/sdf
>> [10:0:0:0]   disk    Seagate  Backup+ Desk     050B  /dev/sdc
>> [11:0:0:0]   disk    Seagate  Expansion Desk   9400  /dev/sdd
>> [12:0:0:0]   disk    Seagate  Backup+ Desk     050B /dev/sde
>> [13:0:0:0]   disk    Seagate  Expansion Desk   9400 /dev/sdg
>> [14:0:0:0]   disk    TOSHIBA  External USB 3.0 5438 /dev/sdl
>> [15:0:0:0]   disk    Seagate  Expansion Desk   9400 /dev/sdh
>> [16:0:0:0]   disk    Seagate  Expansion Desk   9400 /dev/sdi
>> [17:0:0:0]   disk    TOSHIBA  External USB 3.0 5438 /dev/sdm
>> [18:0:0:0]   disk    Seagate  Expansion Desk   9400 /dev/sdj
>> [19:0:0:0]   disk    Seagate  Expansion Desk   9400  /dev/sdk
>>
>> sda is a 6x 1TB RAID5 and sdb is a single 480GB SSD, both on a MegaRAID
>> controller.
>>
>> The rest are 4TB USB drives that I'm experimenting with.
> Which devices did you write when hitting the OOM killer?
sdc, sdd and sde each at max speed, with a little bit of garden variety 
IO on sda and sdb.

----------------------------------------------------------------------
The information contained in this transmission may be confidential. Any disclosure, copying, or further distribution of confidential information is not permitted unless such privilege is explicitly granted in writing by Quantum. Quantum reserves the right to have electronic communications, including email and attachments, sent across its networks filtered through anti virus and spam software programs and retain such messages in order to comply with applicable data security and retention requirements. Quantum is not responsible for the proper and complete transmission of the substance of this communication or for any delay in its receipt.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
