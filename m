Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7959C6B0003
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 18:46:02 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id q23so25899341otg.9
        for <linux-mm@kvack.org>; Fri, 19 Oct 2018 15:46:02 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id v17si10930900otk.261.2018.10.19.15.46.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Oct 2018 15:46:01 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: Re: [RFC PATCH 0/2] improve vmalloc allocation
Date: Fri, 19 Oct 2018 22:44:39 +0000
Message-ID: <20181019224432.GA616@tower.DHCP.thefacebook.com>
References: <20181019173538.590-1-urezki@gmail.com>
In-Reply-To: <20181019173538.590-1-urezki@gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <4C67FFCE1E1F254D917A38028823A9C3@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Thomas
 Garnier <thgarnie@google.com>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>, Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>

On Fri, Oct 19, 2018 at 07:35:36PM +0200, Uladzislau Rezki (Sony) wrote:
> Objective
> ---------
> Initiative of improving vmalloc allocator comes from getting many issues
> related to allocation time, i.e. sometimes it is terribly slow. As a resu=
lt
> many workloads which are sensitive for long (more than 1 millisecond) pre=
emption
> off scenario are affected by that slowness(test cases like UI or audio, e=
tc.).
>=20
> The problem is that, currently an allocation of the new VA area is done o=
ver
> busy list iteration until a suitable hole is found between two busy areas=
.
> Therefore each new allocation causes the list being grown. Due to long li=
st
> and different permissive parameters an allocation can take a long time on
> embedded devices(milliseconds).
...
> 3) This one is related to PCPU allocator(see pcpu_alloc_test()). In that
> stress test case i see that SUnreclaim(/proc/meminfo) parameter gets incr=
eased,
> i.e. there is a memory leek somewhere in percpu allocator. It sounds like
> a memory that is allocated by pcpu_get_vm_areas() sometimes is not freed.
> Resulting in memory leaking or "Kernel panic":
>=20

Can you, please, try the following patch:
6685b357363b ("percpu: stop leaking bitmap metadata blocks") ?

BTW, with growing number of vmalloc users (per-cpu allocator and bpf stuff =
are
big drivers), I find the patchset very interesting.

Thanks!
