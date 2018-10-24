Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 04E886B0277
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 07:00:37 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id d7-v6so3054435pfj.6
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 04:00:36 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id j184-v6si4407988pfg.210.2018.10.24.04.00.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Oct 2018 04:00:35 -0700 (PDT)
Subject: Re: Redoing eXclusive Page Frame Ownership (XPFO) with isolated CPUs
 in mind (for KVM to isolate its guests per CPU)
From: Khalid Aziz <khalid.aziz@oracle.com>
References: <CA+55aFxyUdhYjnQdnmWAt8tTwn4HQ1xz3SAMZJiawkLpMiJ_+w@mail.gmail.com>
 <ciirm8a7p3alos.fsf@u54ee758033e858cfa736.ant.amazon.com>
 <CA+55aFzHj_GNZWG4K2oDu4DPP9sZdTZ9PY7sBxGB6WoN9g8d=A@mail.gmail.com>
 <ciirm8zhwyiqh4.fsf@u54ee758033e858cfa736.ant.amazon.com>
 <ciirm8efdy916l.fsf@u54ee758033e858cfa736.ant.amazon.com>
 <5efc291c-b0ed-577e-02d1-285d080c293d@oracle.com>
 <ciirm8va743105.fsf@u54ee758033e858cfa736.ant.amazon.com>
 <7221975d-6b67-effa-2747-06c22c041e78@oracle.com>
 <1537800341.9745.20.camel@amazon.de>
 <063f5efc-afb2-471f-eb4b-79bf90db22dd@oracle.com>
Message-ID: <6cc985bb-6aed-4fb7-0ef2-43aad2717095@oracle.com>
Date: Wed, 24 Oct 2018 16:30:42 +0530
MIME-Version: 1.0
In-Reply-To: <063f5efc-afb2-471f-eb4b-79bf90db22dd@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Stecklina, Julian" <jsteckli@amazon.de>
Cc: "juerg.haefliger@hpe.com" <juerg.haefliger@hpe.com>, "deepa.srinivasan@oracle.com" <deepa.srinivasan@oracle.com>, "jmattson@google.com" <jmattson@google.com>, "andrew.cooper3@citrix.com" <andrew.cooper3@citrix.com>, "Woodhouse, David" <dwmw@amazon.co.uk>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>, "pradeep.vincent@oracle.com" <pradeep.vincent@oracle.com>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "kanth.ghatraju@oracle.com" <kanth.ghatraju@oracle.com>, "joao.m.martins@oracle.com" <joao.m.martins@oracle.com>, "liran.alon@oracle.com" <liran.alon@oracle.com>, "ak@linux.intel.com" <ak@linux.intel.com>, "keescook@google.com" <keescook@google.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "chris.hyser@oracle.com" <chris.hyser@oracle.com>, "tyhicks@canonical.com" <tyhicks@canonical.com>, "john.haxby@oracle.com" <john.haxby@oracle.com>, "jcm@redhat.com" <jcm@redhat.com>

On 10/15/2018 01:37 PM, Khalid Aziz wrote:
> On 09/24/2018 08:45 AM, Stecklina, Julian wrote:
>> I didn't test the version with TLB flushes, because it's clear that the
>> overhead is so bad that no one wants to use this.
> 
> I don't think we can ignore the vulnerability caused by not flushing 
> stale TLB entries. On a mostly idle system, TLB entries hang around long 
> enough to make it fairly easy to exploit this. I was able to use the 
> additional test in lkdtm module added by this patch series to 
> successfully read pages unmapped from physmap by just waiting for system 
> to become idle. A rogue program can simply monitor system load and mount 
> its attack using ret2dir exploit when system is mostly idle. This brings 
> us back to the prohibitive cost of TLB flushes. If we are unmapping a 
> page from physmap every time the page is allocated to userspace, we are 
> forced to incur the cost of TLB flushes in some way. Work Tycho was 
> doing to implement Dave's suggestion can help here. Once Tycho has 
> something working, I can measure overhead on my test machine. Tycho, I 
> can help with your implementation if you need.

I looked at Tycho's last patch with batch update from 
<https://lkml.org/lkml/2017/11/9/951>. I ported it on top of Julian's 
patches and got it working well enough to gather performance numbers. 
Here is what I see for system times on a machine with dual Xeon E5-2630 
and 256GB of memory when running "make -j30 all" on 4.18.6 kernel 
(percentages are relative to base 4.19-rc8 kernel without xpfo):


Base 4.19-rc8				913.84s
4.19-rc8 + xpfo, no TLB flush		1027.985s (+12.5%)
4.19-rc8 + batch update, no TLB flush	970.39s (+6.2%)
4.19-rc8 + xpfo, TLB flush		8458.449s (+825.6%)
4.19-rc8 + batch update, TLB flush	4665.659s (+410.6%)

Batch update is significant improvement but we are starting so far 
behind baseline, it is still a huge slow down.

--
Khalid
