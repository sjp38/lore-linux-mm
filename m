Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id AAF7C6B0035
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 15:00:08 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so682891pab.1
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 12:00:08 -0700 (PDT)
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com. [202.81.31.142])
        by mx.google.com with ESMTPS id k7si1086844pdn.511.2014.07.03.12.00.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 03 Jul 2014 12:00:07 -0700 (PDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Fri, 4 Jul 2014 05:00:03 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id DBE742CE8040
	for <linux-mm@kvack.org>; Fri,  4 Jul 2014 05:00:00 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s63IhS4O52428940
	for <linux-mm@kvack.org>; Fri, 4 Jul 2014 04:43:28 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s63IxxTG025442
	for <linux-mm@kvack.org>; Fri, 4 Jul 2014 05:00:00 +1000
Message-ID: <53B5A769.5030108@linux.vnet.ibm.com>
Date: Fri, 04 Jul 2014 00:26:41 +0530
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm readahead: Fix sys_readahead breakage by reverting
 2MB limit (bug 79111)
References: <1404392547-11648-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <CA+55aFxOTqUAqEF7+83s890Q18qCHSQqDOxWqWHNjG_25hVhXg@mail.gmail.com> <53B59CB5.9060004@linux.vnet.ibm.com> <CA+55aFyRgYW6Y8paYKGfqE205enhiPsZ1C8wrKpFavVXq7ZAtA@mail.gmail.com> <CA+55aFwwSCrH5QDvrzzyHhRU5R849Mo8A3NdRMwm9OTeWH9diQ@mail.gmail.com> <53B5A343.4090402@linux.vnet.ibm.com> <CA+55aFyqK90YJkjtHR2QGFt4Mvn=mj8a4FkB_8nbTTj3=jp3NA@mail.gmail.com>
In-Reply-To: <CA+55aFyqK90YJkjtHR2QGFt4Mvn=mj8a4FkB_8nbTTj3=jp3NA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, David Rientjes <rientjes@google.com>, Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 07/04/2014 12:23 AM, Linus Torvalds wrote:
> On Thu, Jul 3, 2014 at 11:38 AM, Raghavendra K T
> <raghavendra.kt@linux.vnet.ibm.com> wrote:
>>
>> Okay, how about something like 256MB? I would be happy to send a patch
>> for that change.
>
> I'd like to see some performance numbers. I know at least Fedora uses
> "readahead()" in the startup scripts, do we have any performance
> numbers for that?
>
> Also, I think 256MB is actually excessive. People still do have really
> slow devices out there. USB-2 is still common, and drives that read at
> 15MB/s are not unusual. Do we really want to do readahead() that can
> take tens of seconds (and *will* take tens of seconds sycnhronously,
> because the IO requests fill up).
>
> So I wouldn't go from 2 to 256. That seems like an excessive jump. I
> was more thinking in the 4-8MB range. But even then, I think we should
> always have technical reasons (ie preferably numbers) for the change,
> not just randomly change it.

Okay. I 'll take some time to do the analysis. I think we also should
keep in mind of possible remote readahead that would cause unnecessary
penalty.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
