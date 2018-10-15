Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2F89B6B000A
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 04:07:45 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id r81-v6so19235987pfk.11
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 01:07:45 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id g5-v6si10481598plm.320.2018.10.15.01.07.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 01:07:44 -0700 (PDT)
From: Khalid Aziz <khalid.aziz@oracle.com>
Subject: Re: Redoing eXclusive Page Frame Ownership (XPFO) with isolated CPUs
 in mind (for KVM to isolate its guests per CPU)
References: <CA+55aFxyUdhYjnQdnmWAt8tTwn4HQ1xz3SAMZJiawkLpMiJ_+w@mail.gmail.com>
 <ciirm8a7p3alos.fsf@u54ee758033e858cfa736.ant.amazon.com>
 <CA+55aFzHj_GNZWG4K2oDu4DPP9sZdTZ9PY7sBxGB6WoN9g8d=A@mail.gmail.com>
 <ciirm8zhwyiqh4.fsf@u54ee758033e858cfa736.ant.amazon.com>
 <ciirm8efdy916l.fsf@u54ee758033e858cfa736.ant.amazon.com>
 <5efc291c-b0ed-577e-02d1-285d080c293d@oracle.com>
 <ciirm8va743105.fsf@u54ee758033e858cfa736.ant.amazon.com>
 <7221975d-6b67-effa-2747-06c22c041e78@oracle.com>
 <1537800341.9745.20.camel@amazon.de>
Message-ID: <063f5efc-afb2-471f-eb4b-79bf90db22dd@oracle.com>
Date: Mon, 15 Oct 2018 02:07:17 -0600
MIME-Version: 1.0
In-Reply-To: <1537800341.9745.20.camel@amazon.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Stecklina, Julian" <jsteckli@amazon.de>
Cc: "juerg.haefliger@hpe.com" <juerg.haefliger@hpe.com>, "deepa.srinivasan@oracle.com" <deepa.srinivasan@oracle.com>, "jmattson@google.com" <jmattson@google.com>, "andrew.cooper3@citrix.com" <andrew.cooper3@citrix.com>, "Woodhouse, David" <dwmw@amazon.co.uk>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>, "pradeep.vincent@oracle.com" <pradeep.vincent@oracle.com>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "kanth.ghatraju@oracle.com" <kanth.ghatraju@oracle.com>, "joao.m.martins@oracle.com" <joao.m.martins@oracle.com>, "liran.alon@oracle.com" <liran.alon@oracle.com>, "ak@linux.intel.com" <ak@linux.intel.com>, "keescook@google.com" <keescook@google.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "chris.hyser@oracle.com" <chris.hyser@oracle.com>, "tyhicks@canonical.com" <tyhicks@canonical.com>, "john.haxby@oracle.com" <john.haxby@oracle.com>, "jcm@redhat.com" <jcm@redhat.com>

On 09/24/2018 08:45 AM, Stecklina, Julian wrote:
> I didn't test the version with TLB flushes, because it's clear that the
> overhead is so bad that no one wants to use this.

I don't think we can ignore the vulnerability caused by not flushing 
stale TLB entries. On a mostly idle system, TLB entries hang around long 
enough to make it fairly easy to exploit this. I was able to use the 
additional test in lkdtm module added by this patch series to 
successfully read pages unmapped from physmap by just waiting for system 
to become idle. A rogue program can simply monitor system load and mount 
its attack using ret2dir exploit when system is mostly idle. This brings 
us back to the prohibitive cost of TLB flushes. If we are unmapping a 
page from physmap every time the page is allocated to userspace, we are 
forced to incur the cost of TLB flushes in some way. Work Tycho was 
doing to implement Dave's suggestion can help here. Once Tycho has 
something working, I can measure overhead on my test machine. Tycho, I 
can help with your implementation if you need.

--
Khalid
