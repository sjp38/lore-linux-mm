Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 978D36B00E9
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 21:41:21 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zhong@linux.vnet.ibm.com>;
	Thu, 19 Apr 2012 07:11:17 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3J1etGv4493482
	for <linux-mm@kvack.org>; Thu, 19 Apr 2012 07:10:59 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3J7AAcV012533
	for <linux-mm@kvack.org>; Thu, 19 Apr 2012 17:10:10 +1000
Message-ID: <1334799635.10478.9.camel@ThinkPad-T420>
Subject: Re: [PATCH mm] limit the mm->map_count not greater than
 sysctl_max_map_count
From: Li Zhong <zhong@linux.vnet.ibm.com>
Date: Wed, 18 Apr 2012 21:40:35 -0400
In-Reply-To: <4F8EC161.5050307@gmail.com>
References: <1334741239.30072.7.camel@ThinkPad-T420>
	 <4F8EC161.5050307@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org

On Wed, 2012-04-18 at 21:28 +0800, Cong Wang wrote:
> On 04/18/2012 05:27 PM, Li Zhong wrote:
> > When reading the mmap codes, I found the checking of mm->map_count
> > against sysctl_max_map_count is not consistent. At some places, ">" is
> > used; at some other places, ">=" is used.
> >
> > This patch changes ">" to">=", so they are consistent, and makes sure
> > the value is not greater (one more) than sysctl_max_map_count.
> >
> 
> Well, according to Documentation/sysctl/vm.txt,
> 
> max_map_count:
> 
> This file contains the maximum number of memory map areas a process
> may have. [...]
> 
> I think ->map_count == sysctl_max_map_count should be allowed, so using 
> '>' is correct.
> 
Yes, I agree that ->map_count == sysctl_max_map_count should be allowed.
However, with '>' used. The ->map_count could be sysctl_max_map_count+1.
It could be seen with a simple program doing continuously mmaping of a
file. 

( Still it is possible, as stated in the comments of do_munmap code, if
the VMA is going to be divided into two, the map_count could temporarily
be sysctl_max_map_count+1, after the original vma split into two, and
before one of the two vmas removed. ) 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
