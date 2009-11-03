Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D52E46B0062
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 09:38:50 -0500 (EST)
Message-ID: <4AF04076.2070409@redhat.com>
Date: Tue, 03 Nov 2009 16:38:46 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 03/11] Handle asynchronous page fault in a PV guest.
References: <1257076590-29559-1-git-send-email-gleb@redhat.com> <1257076590-29559-4-git-send-email-gleb@redhat.com> <20091103141423.GC10084@amt.cnet> <20091103142533.GN27911@redhat.com> <20091103143250.GD10084@amt.cnet>
In-Reply-To: <20091103143250.GD10084@amt.cnet>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: Gleb Natapov <gleb@redhat.com>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 11/03/2009 04:32 PM, Marcelo Tosatti wrote:
> Any attempt to access the swapped out data will cause a #PF vmexit,
> since the translation is marked as not present. If there's swapin in
> progress, you wait for that swapin, otherwise start swapin and wait.
>
> Its not as efficient as paravirt because you have to wait for a timer
> interrupt and the guest scheduler to decide to taskswitch, but OTOH its
> transparent.
>    

With a dyntick guest the timer interrupt will come at the end of the 
time slice, likely after the page has been swapped in.  That leaves smp 
reschedule interrupts and non-dyntick guests.

An advantage is that there is one code path for apf and non-apf.  
Another is that interrupts are processed, improving timekeeping and 
maybe responsiveness.


-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
