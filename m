Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 55FE78E0001
	for <linux-mm@kvack.org>; Mon, 17 Sep 2018 05:51:52 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id s1-v6so13988036qte.19
        for <linux-mm@kvack.org>; Mon, 17 Sep 2018 02:51:52 -0700 (PDT)
Received: from smtp-fw-9101.amazon.com (smtp-fw-9101.amazon.com. [207.171.184.25])
        by mx.google.com with ESMTPS id b27-v6si5206679qvh.18.2018.09.17.02.51.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Sep 2018 02:51:51 -0700 (PDT)
From: Julian Stecklina <jsteckli@amazon.de>
Subject: Re: Redoing eXclusive Page Frame Ownership (XPFO) with isolated CPUs in mind (for KVM to isolate its guests per CPU)
References: <CA+55aFxyUdhYjnQdnmWAt8tTwn4HQ1xz3SAMZJiawkLpMiJ_+w@mail.gmail.com>
	<ciirm8a7p3alos.fsf@u54ee758033e858cfa736.ant.amazon.com>
	<CA+55aFzHj_GNZWG4K2oDu4DPP9sZdTZ9PY7sBxGB6WoN9g8d=A@mail.gmail.com>
	<ciirm8zhwyiqh4.fsf@u54ee758033e858cfa736.ant.amazon.com>
	<ciirm8efdy916l.fsf@u54ee758033e858cfa736.ant.amazon.com>
	<5efc291c-b0ed-577e-02d1-285d080c293d@oracle.com>
Date: Mon, 17 Sep 2018 11:51:38 +0200
In-Reply-To: <5efc291c-b0ed-577e-02d1-285d080c293d@oracle.com> (Khalid Aziz's
	message of "Fri, 14 Sep 2018 11:06:53 -0600")
Message-ID: <ciirm8va743105.fsf@u54ee758033e858cfa736.ant.amazon.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, David Woodhouse <dwmw@amazon.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, juerg.haefliger@hpe.com, deepa.srinivasan@oracle.com, Jim Mattson <jmattson@google.com>, Andrew Cooper <andrew.cooper3@citrix.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, joao.m.martins@oracle.com, pradeep.vincent@oracle.com, Andi Kleen <ak@linux.intel.com>, kanth.ghatraju@oracle.com, Liran Alon <liran.alon@oracle.com>, Kees Cook <keescook@google.com>, Kernel Hardening <kernel-hardening@lists.openwall.com>, chris.hyser@oracle.com, Tyler Hicks <tyhicks@canonical.com>, John Haxby <john.haxby@oracle.com>, Jon Masters <jcm@redhat.com>

Khalid Aziz <khalid.aziz@oracle.com> writes:

> I ran tests with your updated code and gathered lock statistics. Change in
> system time for "make -j60" was in the noise margin (It actually went up by
> about 2%). There is some contention on xpfo_lock. Average wait time does not
> look high compared to other locks. Max hold time looks a little long. From
> /proc/lock_stat:
>
>               &(&page->xpfo_lock)->rlock:         29698          29897           0.06         134.39       15345.58           0.51      422474670      960222532           0.05       30362.05   195807002.62           0.20
>
> Nevertheless even a smaller average wait time can add up.

Thanks for doing this!

I've spent some time optimizing spinlock usage in the code. See the two
last commits in my xpfo-master branch[1]. The optimization in
xpfo_kunmap is pretty safe. The last commit that optimizes locking in
xpfo_kmap is tricky, though, and I'm not sure this is the right
approach. FWIW, I've modeled this locking strategy in Spin and it
doesn't find any problems with it.

I've tested the result on a box with 72 hardware threads and I didn't
see a meaningful difference in kernel compile performance. It's still
hovering around 2%. So the question is, whether it's actually useful to
do these optimizations.

Khalid, you mentioned 5% overhead. Can you give the new code a spin and
see whether anything changes?

Julian

[1] http://git.infradead.org/users/jsteckli/linux-xpfo.git/shortlog/refs/heads/xpfo-master

--
Amazon Development Center Germany GmbH
Berlin - Dresden - Aachen
main office: Krausenstr. 38, 10117 Berlin
Geschaeftsfuehrer: Dr. Ralf Herbrich, Christian Schlaeger
Ust-ID: DE289237879
Eingetragen am Amtsgericht Charlottenburg HRB 149173 B
