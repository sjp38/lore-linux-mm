From: Andi Kleen <ak@suse.de>
Subject: Re: Some interesting observations when trying to optimize vmstat handling
Date: Fri, 9 Nov 2007 00:07:42 +0100
References: <Pine.LNX.4.64.0711081141180.9694@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0711081141180.9694@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200711090007.43424.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
List-ID: <linux-mm.kvack.org>

> There is an interrupt enable overhead of 48 cycles that would be good to
> be able to eliminate (Kernel code usually moves counter increments into
> a neighboring interrupt disable section so that __ function can be used).

Replace the push flags ; popf  with test $IFMASK,flags ; jz 1f; sti ; 1:
That will likely make it much faster (but also bigger) 

The only problem is that there might be some code who relies on 
restore_flags() restoring other flags that IF, but at least for interrupts
and local_irq_save/restore it should be fine to change.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
