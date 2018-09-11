Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 524388E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 20:38:50 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id n17-v6so11878901pff.17
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 17:38:50 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id k14-v6si19108924pfd.0.2018.09.10.17.38.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 17:38:49 -0700 (PDT)
Subject: Re: Plumbers 2018 - Performance and Scalability Microconference
References: <1dc80ff6-f53f-ae89-be29-3408bf7d69cc@oracle.com>
 <35c2c79f-efbe-f6b2-43a6-52da82145638@nvidia.com>
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Message-ID: <0f49f722-1759-f097-ff46-4ec7286dc69e@oracle.com>
Date: Mon, 10 Sep 2018 20:38:35 -0400
MIME-Version: 1.0
In-Reply-To: <35c2c79f-efbe-f6b2-43a6-52da82145638@nvidia.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Aaron Lu <aaron.lu@intel.com>, alex.kogan@oracle.com, akpm@linux-foundation.org, boqun.feng@gmail.com, brouer@redhat.com, dave@stgolabs.net, dave.dice@oracle.com, Dhaval Giani <dhaval.giani@oracle.com>, ktkhai@virtuozzo.com, ldufour@linux.vnet.ibm.com, Pavel.Tatashin@microsoft.com, paulmck@linux.vnet.ibm.com, shady.issa@oracle.com, tariqt@mellanox.com, tglx@linutronix.de, tim.c.chen@intel.com, vbabka@suse.cz, longman@redhat.com, yang.shi@linux.alibaba.com, shy828301@gmail.com, Huang Ying <ying.huang@intel.com>, subhra.mazumdar@oracle.com, Steven Sistare <steven.sistare@oracle.com>, jwadams@google.com, ashwinch@google.com, sqazi@google.com, Shakeel Butt <shakeelb@google.com>, walken@google.com, rientjes@google.com, junaids@google.com, Neha Agarwal <nehaagarwal@google.com>

On 9/8/18 12:13 AM, John Hubbard wrote:
> I'm interested in the first 3 of those 4 topics, so if it doesn't conflict with HMM topics or
> fix-gup-with-dma topics, I'd like to attend.

Great, we'll add your name to the list.

> GPUs generally need to access large chunks of
> memory, and that includes migrating (dma-copying) pages around.
> 
> So for example a multi-threaded migration of huge pages between normal RAM and GPU memory is an
> intriguing direction (and I realize that it's a well-known topic, already). Doing that properly
> (how many threads to use?) seems like it requires scheduler interaction.

Yes, in past discussions of multithreading kernel work, there's been some discussion of a scheduler API that could answer "are there idle CPUs we could use to multithread?".

Instead of adding an interface, though, we could just let the scheduler do something it already knows how to do: prioritize.

Additional threads used to parallelize kernel work could run at the lowest priority (i.e. MAX_NICE).  If the machine is heavily loaded, these extra threads simply won't run and other workloads on the system will be unaffected.

There's the issue of priority inversion if one or more of those extra threads get started and are then preempted by normal-priority tasks midway through, but the main thread doing the job can just will its priority to each worker in turn once it's finished, so at most one thread will be active on a heavily loaded system, again leaving other workloads on the system undisturbed.
