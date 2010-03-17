Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4CF9F6B01B3
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 11:55:52 -0400 (EDT)
Received: by pzk30 with SMTP id 30so639980pzk.12
        for <linux-mm@kvack.org>; Wed, 17 Mar 2010 08:55:50 -0700 (PDT)
Message-ID: <4BA0FB83.1010502@codemonkey.ws>
Date: Wed, 17 Mar 2010 10:55:47 -0500
From: Anthony Liguori <anthony@codemonkey.ws>
MIME-Version: 1.0
Subject: Re: [PATCH][RF C/T/D] Unmapped page cache control - via boot parameter
References: <20100315072214.GA18054@balbir.in.ibm.com> <4B9DE635.8030208@redhat.com> <20100315080726.GB18054@balbir.in.ibm.com> <4B9DEF81.6020802@redhat.com> <20100315202353.GJ3840@arachsys.com> <4B9EC60A.2070101@codemonkey.ws> <20100317151409.GY31148@arachsys.com>
In-Reply-To: <20100317151409.GY31148@arachsys.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Chris Webb <chris@arachsys.com>
Cc: Avi Kivity <avi@redhat.com>, balbir@linux.vnet.ibm.com, KVM development list <kvm@vger.kernel.org>, Rik van Riel <riel@surriel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 03/17/2010 10:14 AM, Chris Webb wrote:
> Anthony Liguori<anthony@codemonkey.ws>  writes:
>
>    
>> This really gets down to your definition of "safe" behaviour.  As it
>> stands, if you suffer a power outage, it may lead to guest
>> corruption.
>>
>> While we are correct in advertising a write-cache, write-caches are
>> volatile and should a drive lose power, it could lead to data
>> corruption.  Enterprise disks tend to have battery backed write
>> caches to prevent this.
>>
>> In the set up you're emulating, the host is acting as a giant write
>> cache.  Should your host fail, you can get data corruption.
>>      
> Hi Anthony. I suspected my post might spark an interesting discussion!
>
> Before considering anything like this, we did quite a bit of testing with
> OSes in qemu-kvm guests running filesystem-intensive work, using an ipmitool
> power off to kill the host. I didn't manage to corrupt any ext3, ext4 or
> NTFS filesystems despite these efforts.
>
> Is your claim here that:-
>
>    (a) qemu doesn't emulate a disk write cache correctly; or
>
>    (b) operating systems are inherently unsafe running on top of a disk with
>        a write-cache; or
>
>    (c) installations that are already broken and lose data with a physical
>        drive with a write-cache can lose much more in this case because the
>        write cache is much bigger?
>    

This is the closest to the most accurate.

It basically boils down to this: most enterprises use a disks with 
battery backed write caches.  Having the host act as a giant write cache 
means that you can lose data.

I agree that a well behaved file system will not become corrupt, but my 
contention is that for many types of applications, data lose == 
corruption and not all file systems are well behaved.  And it's 
certainly valid to argue about whether common filesystems are "broken" 
but from a purely pragmatic perspective, this is going to be the case.

Regards,

Anthony Liguori

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
