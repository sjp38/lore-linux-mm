Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 847316B01EF
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 19:43:11 -0400 (EDT)
Received: by gyb13 with SMTP id 13so922889gyb.14
        for <linux-mm@kvack.org>; Mon, 15 Mar 2010 16:43:09 -0700 (PDT)
Message-ID: <4B9EC60A.2070101@codemonkey.ws>
Date: Mon, 15 Mar 2010 18:43:06 -0500
From: Anthony Liguori <anthony@codemonkey.ws>
MIME-Version: 1.0
Subject: Re: [PATCH][RF C/T/D] Unmapped page cache control - via boot parameter
References: <20100315072214.GA18054@balbir.in.ibm.com> <4B9DE635.8030208@redhat.com> <20100315080726.GB18054@balbir.in.ibm.com> <4B9DEF81.6020802@redhat.com> <20100315202353.GJ3840@arachsys.com>
In-Reply-To: <20100315202353.GJ3840@arachsys.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Chris Webb <chris@arachsys.com>
Cc: Avi Kivity <avi@redhat.com>, balbir@linux.vnet.ibm.com, KVM development list <kvm@vger.kernel.org>, Rik van Riel <riel@surriel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 03/15/2010 03:23 PM, Chris Webb wrote:
> Avi Kivity<avi@redhat.com>  writes:
>
>    
>> On 03/15/2010 10:07 AM, Balbir Singh wrote:
>>
>>      
>>> Yes, it is a virtio call away, but is the cost of paying twice in
>>> terms of memory acceptable?
>>>        
>> Usually, it isn't, which is why I recommend cache=off.
>>      
> Hi Avi. One observation about your recommendation for cache=none:
>
> We run hosts of VMs accessing drives backed by logical volumes carved out
> from md RAID1. Each host has 32GB RAM and eight cores, divided between (say)
> twenty virtual machines, which pretty much fill the available memory on the
> host. Our qemu-kvm is new enough that IDE and SCSI drives with writeback
> caching turned on get advertised to the guest as having a write-cache, and
> FLUSH gets translated to fsync() by qemu. (Consequently cache=writeback
> isn't acting as cache=neverflush like it would have done a year ago. I know
> that comparing performance for cache=none against that unsafe behaviour
> would be somewhat unfair!)
>    

I knew someone would do this...

This really gets down to your definition of "safe" behaviour.  As it 
stands, if you suffer a power outage, it may lead to guest corruption.

While we are correct in advertising a write-cache, write-caches are 
volatile and should a drive lose power, it could lead to data 
corruption.  Enterprise disks tend to have battery backed write caches 
to prevent this.

In the set up you're emulating, the host is acting as a giant write 
cache.  Should your host fail, you can get data corruption.

cache=writethrough provides a much stronger data guarantee.  Even in the 
event of a host failure, data integrity will be preserved.

Regards,

Anthony Liguori

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
