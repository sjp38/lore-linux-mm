Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 935446B1BA2
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 19:27:21 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id g5-v6so6916920pgq.5
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 16:27:21 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id b82-v6si12266332pfb.18.2018.08.20.16.27.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Aug 2018 16:27:20 -0700 (PDT)
Subject: Re: Redoing eXclusive Page Frame Ownership (XPFO) with isolated CPUs
 in mind (for KVM to isolate its guests per CPU)
References: <20180820212556.GC2230@char.us.oracle.com>
 <CA+55aFxZCyVZc4ZpRyZ3uDyakRSOG_=2XvnwMo4oejpsieF9=A@mail.gmail.com>
 <1534801939.10027.24.camel@amazon.co.uk>
 <CA+55aFxyUdhYjnQdnmWAt8tTwn4HQ1xz3SAMZJiawkLpMiJ_+w@mail.gmail.com>
 <20180820223557.GC16961@cisco.cisco.com>
 <bd148fb6-e139-a065-1bf5-8054f932d30a@intel.com>
 <1534806880.10027.29.camel@infradead.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <dd9657d2-f1c1-630d-4cce-7f1c67a968d6@intel.com>
Date: Mon, 20 Aug 2018 16:26:32 -0700
MIME-Version: 1.0
In-Reply-To: <1534806880.10027.29.camel@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Woodhouse <dwmw2@infradead.org>, Tycho Andersen <tycho@tycho.ws>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, juerg.haefliger@hpe.com, deepa.srinivasan@oracle.com, Jim Mattson <jmattson@google.com>, Andrew Cooper <andrew.cooper3@citrix.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, joao.m.martins@oracle.com, pradeep.vincent@oracle.com, Andi Kleen <ak@linux.intel.com>, Khalid Aziz <khalid.aziz@oracle.com>, kanth.ghatraju@oracle.com, Liran Alon <liran.alon@oracle.com>, Kees Cook <keescook@google.com>, jsteckli@os.inf.tu-dresden.de, Kernel Hardening <kernel-hardening@lists.openwall.com>, chris.hyser@oracle.com, Tyler Hicks <tyhicks@canonical.com>, John Haxby <john.haxby@oracle.com>, Jon Masters <jcm@redhat.com>

On 08/20/2018 04:14 PM, David Woodhouse wrote:
> If you need the physmap, then rather than manually mapping with 4KiB
> pages, you just switch. Having first ensured that no malicious guest or
> userspace is running on a sibling, of course.

The problem is determining when "you need the physmap".  Tycho's
patches, as I remember them basically classify pages between being
"user" pages which are accessed only via kmap() and friends and "kernel"
pages which need to be mapped all the time because they might have a
'task_struct' or a page table or a 'struct file'.

You're right that we could have a full physmap that we switch to for
kmap()-like access to user pages.  But, the real problem is
transitioning pages from kernel to user usage since it requires shooting
down the old kernel mappings for those pages in some way.
