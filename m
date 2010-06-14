Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 675546B01B7
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 04:09:47 -0400 (EDT)
Message-ID: <4C15E3C8.20407@redhat.com>
Date: Mon, 14 Jun 2010 11:09:44 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC/T/D][PATCH 2/2] Linux/Guest cooperative unmapped page cache
 control
References: <20100608155140.3749.74418.sendpatchset@L34Z31A.ibm.com> <20100608155153.3749.31669.sendpatchset@L34Z31A.ibm.com> <4C10B3AF.7020908@redhat.com> <20100610142512.GB5191@balbir.in.ibm.com> <1276214852.6437.1427.camel@nimitz> <20100611045600.GE5191@balbir.in.ibm.com>
In-Reply-To: <20100611045600.GE5191@balbir.in.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, kvm <kvm@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 06/11/2010 07:56 AM, Balbir Singh wrote:
>
>> Just to be clear, let's say we have a mapped page (say of /sbin/init)
>> that's been unreferenced since _just_ after the system booted.  We also
>> have an unmapped page cache page of a file often used at runtime, say
>> one from /etc/resolv.conf or /etc/passwd.
>>
>> Which page will be preferred for eviction with this patch set?
>>
>>      
> In this case the order is as follows
>
> 1. First we pick free pages if any
> 2. If we don't have free pages, we go after unmapped page cache and
> slab cache
> 3. If that fails as well, we go after regularly memory
>
> In the scenario that you describe, we'll not be able to easily free up
> the frequently referenced page from /etc/*. The code will move on to
> step 3 and do its regular reclaim.
>    

Still it seems to me you are subverting the normal order of reclaim.  I 
don't see why an unmapped page cache or slab cache item should be 
evicted before a mapped page.  Certainly the cost of rebuilding a dentry 
compared to the gain from evicting it, is much higher than that of 
reestablishing a mapped page.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
