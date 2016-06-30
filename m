Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 832726B0005
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 13:54:58 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 13so194571854itl.0
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 10:54:58 -0700 (PDT)
Received: from mail-it0-x242.google.com (mail-it0-x242.google.com. [2607:f8b0:4001:c0b::242])
        by mx.google.com with ESMTPS id x195si49456itx.92.2016.06.30.10.54.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jun 2016 10:54:57 -0700 (PDT)
Received: by mail-it0-x242.google.com with SMTP id h190so9805834ith.3
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 10:54:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160630165248.GB4650@linux.vnet.ibm.com>
References: <CAMuHMdVqNV5ZbR3_NV5ZsLxoNQUXXGpfAcaoMJffaJbRPUb6-A@mail.gmail.com>
 <20160629164415.GG4650@linux.vnet.ibm.com> <CAMuHMdUfQ-gBqjZGvawf5zxgb-0UnWb+fzD-kcWU+kavwvadgQ@mail.gmail.com>
 <20160629181208.GP4650@linux.vnet.ibm.com> <20160630074710.GC30114@js1304-P5Q-DELUXE>
 <CAMuHMdVx4p9=CNCwZuuUyxsYZGN7VPs7F+RbysQjYGSY25TPQA@mail.gmail.com>
 <20160630132401.GT4650@linux.vnet.ibm.com> <CAMuHMdVTX3ojMsO5Mv++pA5r+st4yBTTo39QTbV-FxPmJ7fbkQ@mail.gmail.com>
 <20160630151838.GW4650@linux.vnet.ibm.com> <alpine.DEB.2.10.1606301752410.6474@ayla.of.borg>
 <20160630165248.GB4650@linux.vnet.ibm.com>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Thu, 30 Jun 2016 19:54:56 +0200
Message-ID: <CAMuHMdVRpbVSJmVqqwEiZUJq+q5vt6Me+O72i_8Y2pAPtkLY7w@mail.gmail.com>
Subject: Re: Boot failure on emev2/kzm9d (was: Re: [PATCH v2 11/11] mm/slab:
 lockless decision to grow cache)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul McKenney <paulmck@linux.vnet.ibm.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-Renesas <linux-renesas-soc@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Linux MM <linux-mm@kvack.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Christoph Lameter <cl@linux.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

Hi Paul,

On Thu, Jun 30, 2016 at 6:52 PM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
> On Thu, Jun 30, 2016 at 05:53:42PM +0200, Geert Uytterhoeven wrote:
>> +void rcu_dump_rcu_sched_tree(void)
>> +{
>> +     struct rcu_head rh;
>> +     unsigned long flags;
>> +
>> +     rcu_dump_rcu_node_tree(&rcu_sched_state);  /* Initial state. */
>> +     local_irq_save(flags);
>> +     // call_rcu(&rh, do_nothing_cb);
>> +     local_irq_restore(flags);
>> +     // schedule_timeout_uninterruptible(5 * HZ);  /* Or whatever delay. */
>> +     rcu_dump_rcu_node_tree(&rcu_sched_state); /* GP state. */
>> +     //synchronize_sched();  /* Probably hangs. */
>> +     //rcu_barrier();  /* Drop RCU's references to rh before return. */
>> +}

>>
>> When enabling any of the 4 commented-out lines in rcu_dump_rcu_sched_tree(),
>> it will lock up.
>
> OK, but that includes schedule_timeout_uninterruptible(5 * HZ), right?

Yes it does.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
