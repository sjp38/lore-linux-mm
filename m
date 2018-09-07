Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 12D988E0001
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 17:30:34 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id bh1-v6so7606263plb.15
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 14:30:34 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id d34-v6si8977114pld.301.2018.09.07.14.30.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Sep 2018 14:30:32 -0700 (PDT)
Subject: Re: Redoing eXclusive Page Frame Ownership (XPFO) with isolated CPUs
 in mind (for KVM to isolate its guests per CPU)
References: <ciirm8a7p3alos.fsf@u54ee758033e858cfa736.ant.amazon.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <80a75259-e38b-be94-dc4a-827eddfae931@oracle.com>
Date: Fri, 7 Sep 2018 15:30:10 -0600
MIME-Version: 1.0
In-Reply-To: <ciirm8a7p3alos.fsf@u54ee758033e858cfa736.ant.amazon.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julian Stecklina <jsteckli@amazon.de>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: David Woodhouse <dwmw@amazon.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, juerg.haefliger@hpe.com, deepa.srinivasan@oracle.com, Jim Mattson <jmattson@google.com>, Andrew Cooper <andrew.cooper3@citrix.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, joao.m.martins@oracle.com, pradeep.vincent@oracle.com, Andi Kleen <ak@linux.intel.com>, kanth.ghatraju@oracle.com, Liran Alon <liran.alon@oracle.com>, Kees Cook <keescook@google.com>, Kernel Hardening <kernel-hardening@lists.openwall.com>, chris.hyser@oracle.com, Tyler Hicks <tyhicks@canonical.com>, John Haxby <john.haxby@oracle.com>, Jon Masters <jcm@redhat.com>

On 08/30/2018 10:00 AM, Julian Stecklina wrote:
> Hey everyone,
> 
> On Mon, 20 Aug 2018 15:27 Linus Torvalds <torvalds@linux-foundation.org> wrote:
>> On Mon, Aug 20, 2018 at 3:02 PM Woodhouse, David <dwmw@amazon.co.uk> wrote:
>>>
>>> It's the *kernel* we don't want being able to access those pages,
>>> because of the multitude of unfixable cache load gadgets.
>>
>> Ahh.
>>
>> I guess the proof is in the pudding. Did somebody try to forward-port
>> that patch set and see what the performance is like?
> 
> I've been spending some cycles on the XPFO patch set this week. For the
> patch set as it was posted for v4.13, the performance overhead of
> compiling a Linux kernel is ~40% on x86_64[1]. The overhead comes almost
> completely from TLB flushing. If we can live with stale TLB entries
> allowing temporary access (which I think is reasonable), we can remove
> all TLB flushing (on x86). This reduces the overhead to 2-3% for
> kernel compile.
> 
> There were no problems in forward-porting the patch set to master.
> You can find the result here, including a patch makes the TLB flushing
> configurable:
> http://git.infradead.org/users/jsteckli/linux-xpfo.git/shortlog/refs/heads/xpfo-master
> 
> It survived some casual stress-ng runs. I can rerun the benchmarks on
> this version, but I doubt there is any change.
> 
>> It used to be just 500 LOC. Was that because they took horrible
>> shortcuts?
> 
> The patch is still fairly small. As for the horrible shortcuts, I let
> others comment on that.


Looks like the performance impact can be whole lot worse. On my test 
system with 2 Xeon Platinum 8160 (HT enabled) CPUs and 768 GB of memory, 
I am seeing very high penalty with XPFO when building 4.18.6 kernel 
sources with "make -j60":

              No XPFO patch   XPFO patch(No TLB flush)  XPFO(TLB Flush)
sys time      52m 54.036s       55m 47.897s              434m 8.645s

That is ~8% worse with TLB flush disabled and ~720% worse with TLB flush 
enabled. This test was with kernel sources being compiled on an ext4 
filesystem. XPFO seems to affect ext2 even more. With ext2 filesystem, 
impact was ~18.6% and ~900%.

--
Khalid
