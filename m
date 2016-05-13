Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7FB206B0253
	for <linux-mm@kvack.org>; Fri, 13 May 2016 09:27:21 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id d139so134001641oig.1
        for <linux-mm@kvack.org>; Fri, 13 May 2016 06:27:21 -0700 (PDT)
Received: from mail-io0-x241.google.com (mail-io0-x241.google.com. [2607:f8b0:4001:c06::241])
        by mx.google.com with ESMTPS id z132si1675352itf.63.2016.05.13.06.27.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 06:27:20 -0700 (PDT)
Received: by mail-io0-x241.google.com with SMTP id k129so14837174iof.3
        for <linux-mm@kvack.org>; Fri, 13 May 2016 06:27:20 -0700 (PDT)
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
References: <5731CC6E.3080807@laposte.net>
 <20160513080458.GF20141@dhcp22.suse.cz> <573593EE.6010502@free.fr>
 <20160513095230.GI20141@dhcp22.suse.cz> <5735AA0E.5060605@free.fr>
From: "Austin S. Hemmelgarn" <ahferroin7@gmail.com>
Message-ID: <77b86b3c-69d8-46d5-c667-94082d3f29ea@gmail.com>
Date: Fri, 13 May 2016 09:27:18 -0400
MIME-Version: 1.0
In-Reply-To: <5735AA0E.5060605@free.fr>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mason <slash.tmp@free.fr>, Michal Hocko <mhocko@kernel.org>
Cc: Sebastian Frias <sf84@laposte.net>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 2016-05-13 06:18, Mason wrote:
> On 13/05/2016 11:52, Michal Hocko wrote:
>> On Fri 13-05-16 10:44:30, Mason wrote:
>>> On 13/05/2016 10:04, Michal Hocko wrote:
>>>
>>>> On Tue 10-05-16 13:56:30, Sebastian Frias wrote:
>>>> [...]
>>>>> NOTE: I understand that the overcommit mode can be changed dynamically thru
>>>>> sysctl, but on embedded systems, where we know in advance that overcommit
>>>>> will be disabled, there's no reason to postpone such setting.
>>>>
>>>> To be honest I am not particularly happy about yet another config
>>>> option. At least not without a strong reason (the one above doesn't
>>>> sound that way). The config space is really large already.
>>>> So why a later initialization matters at all? Early userspace shouldn't
>>>> consume too much address space to blow up later, no?
>>>
>>> One thing I'm not quite clear on is: why was the default set
>>> to over-commit on?
>>
>> Because many applications simply rely on large and sparsely used address
>> space, I guess.
>
> What kind of applications are we talking about here?
>
> Server apps? Client apps? Supercomputer apps?
>
> I heard some HPC software use large sparse matrices, but is it a common
> idiom to request large allocations, only to use a fraction of it?
Just looking at my laptop right now, I count the number of processes 
which have a RSS which is more than 25% of their allocated memory to be 
about 15-20 out of ~170 processes and ~360 threads.  Somewhat 
unsurprisingly, most of the ones that fit this are highly purpose 
specific (cachefilesd, syslogd, etc), and the only ones whose RSS is 
within 1% of their allocated memory are BOINC applications (distributed 
and/or scientific computing apps tend to be really good about efficient 
usage of memory, even when they use sparse matrices).  There are in fact 
a lot of 'normal' daemons that do this (sshd on my system for example 
has 460k resident and 28.5M allocated, atd has 122k resident and 12.6M 
allocated, acpid has 120k resident and 4.2M allocated).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
