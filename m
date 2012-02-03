Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id A83B06B13F2
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 10:38:27 -0500 (EST)
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Fri, 3 Feb 2012 15:38:26 -0000
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by d06nrmr1507.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q13Fbme82195538
	for <linux-mm@kvack.org>; Fri, 3 Feb 2012 15:37:48 GMT
Received: from d06av09.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q13Fblh3016562
	for <linux-mm@kvack.org>; Fri, 3 Feb 2012 08:37:48 -0700
Message-ID: <4F2BFF4C.5050905@de.ibm.com>
Date: Fri, 03 Feb 2012 16:37:48 +0100
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Reply-To: gerald.schaefer@de.ibm.com
MIME-Version: 1.0
Subject: Re: ksm/memory hotplug: lockdep warning for ksm_thread_mutex vs.
 (memory_chain).rwsem
References: <4F2AB614.1060907@de.ibm.com> <CAHGf_=rm286b5FWVRQ8Ob0vakxNcNOHPUksCtnZj4PvOEz47Jg@mail.gmail.com>
In-Reply-To: <CAHGf_=rm286b5FWVRQ8Ob0vakxNcNOHPUksCtnZj4PvOEz47Jg@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>, Heiko Carstens <h.carstens@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@sous-sol.org>, Izik Eidus <izik.eidus@ravellosystems.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 03.02.2012 00:00, KOSAKI Motohiro wrote:
> 2012/2/2 Gerald Schaefer<gerald.schaefer@de.ibm.com>:
>> Setting a memory block offline triggers the following lockdep warning. This
>> looks exactly like the issue reported by Kosaki Motohiro in
>> https://lkml.org/lkml/2010/10/25/110. Seems like the resulting commit a0b0f58cdd
>> did not fix the lockdep warning. I'm able to reproduce it with current 3.3.0-rc2
>> as well as 2.6.37-rc4-00147-ga0b0f58.
>>
>> I'm not familiar with lockdep annotations, but I tried using down_read_nested()
>> for (memory_chain).rwsem, similar to the mutex_lock_nested() which was
>> introduced for ksm_thread_mutex, but that didn't help.
> 
> Heh, interesting. Simple question, do you have any user visible buggy
> behavior? or just false positive warn issue?
> 
> *_nested() is just hacky trick. so, any change may break their lie.
> Anyway I'd like to dig this one. thanks for reporting.

There is no real deadlock and no user visible buggy behaviour, the memory is
being offlined as requested. I think your conclusion from last time is still
valid, that both locks are inside mem_hotplug_mutex and there can't be a
deadlock. Question is how to convince lockdep of this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
