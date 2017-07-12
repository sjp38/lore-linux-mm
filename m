Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id DF3B3440874
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 11:44:56 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id c190so20697673ith.3
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 08:44:56 -0700 (PDT)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id z11si3552847iof.191.2017.07.12.08.44.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jul 2017 08:44:55 -0700 (PDT)
Date: Wed, 12 Jul 2017 10:44:54 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: BUG: using __this_cpu_read() in preemptible [00000000] code:
 mm_percpu_wq/7
In-Reply-To: <b7cc8709-5bbf-8a9a-a155-0ea804641e9a@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.20.1707121039180.15771@nuc-kabylake>
References: <b7cc8709-5bbf-8a9a-a155-0ea804641e9a@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andre Wild <wild@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, heiko.carstens@de.ibm.com

On Wed, 7 Jun 2017, Andre Wild wrote:

> I'm currently seeing the following message running kernel version 4.11.0.
> It looks like it was introduced with the patch
> 4037d452202e34214e8a939fa5621b2b3bbb45b7.

A 2007 patch? At that point we did not have __this_cpu_read() nor
refresh_cpu_vmstats.... Is this on s390 or some such architecture?


> Can you please take a look at this problem?

Could you give me a bit more context?


> [Tue Jun  6 15:27:03 2017] BUG: using __this_cpu_read() in preemptible
> [00000000] code: mm_percpu_wq/7
> [Tue Jun  6 15:27:03 2017] caller is refresh_cpu_vm_stats+0x198/0x3d8
> [Tue Jun  6 15:27:03 2017] CPU: 0 PID: 7 Comm: mm_percpu_wq Tainted: G
> W       4.11.0-20170529.0.ae409ab.224a322.fc25.s390xdefault #1
> [Tue Jun  6 15:27:03 2017] Workqueue: mm_percpu_wq vmstat_update

It is run in preemptible mode but this from a kworker
context so the processor cannot change (see vmstat_refresh()).

Even on s390 or so this should be fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
