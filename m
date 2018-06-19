Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id E48F86B0003
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 09:51:33 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id p130-v6so239115itp.2
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 06:51:33 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id k3-v6si7861448jad.99.2018.06.19.06.51.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jun 2018 06:51:32 -0700 (PDT)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w5JDioar083036
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 13:51:31 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2130.oracle.com with ESMTP id 2jmt01g9g9-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 13:51:31 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w5JDpT9A029227
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 13:51:29 GMT
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w5JDpTKE028784
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 13:51:29 GMT
Received: by mail-oi0-f53.google.com with SMTP id i205-v6so18215294oib.1
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 06:51:29 -0700 (PDT)
MIME-Version: 1.0
References: <20171117014601.31606-1-pasha.tatashin@oracle.com>
 <20171121072416.v77vu4osm2s4o5sq@dhcp22.suse.cz> <b16029f0-ada0-df25-071b-cd5dba0ab756@suse.cz>
In-Reply-To: <b16029f0-ada0-df25-071b-cd5dba0ab756@suse.cz>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Tue, 19 Jun 2018 09:50:52 -0400
Message-ID: <CAGM2rea=_VJJ26tohWQWgfwcFVkp0gb6j1edH1kVLjtxfugf5Q@mail.gmail.com>
Subject: Re: [PATCH v1] mm: relax deferred struct page requirements
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jslaby@suse.cz
Cc: mhocko@kernel.org, Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, benh@kernel.crashing.org, paulus@samba.org, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Reza Arbab <arbab@linux.vnet.ibm.com>, schwidefsky@de.ibm.com, Heiko Carstens <heiko.carstens@de.ibm.com>, x86@kernel.org, LKML <linux-kernel@vger.kernel.org>, tglx@linutronix.de, linuxppc-dev@lists.ozlabs.org, Linux Memory Management List <linux-mm@kvack.org>, linux-s390@vger.kernel.org, mgorman@techsingularity.net

On Sat, Jun 16, 2018 at 4:04 AM Jiri Slaby <jslaby@suse.cz> wrote:
>
> On 11/21/2017, 08:24 AM, Michal Hocko wrote:
> > On Thu 16-11-17 20:46:01, Pavel Tatashin wrote:
> >> There is no need to have ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT,
> >> as all the page initialization code is in common code.
> >>
> >> Also, there is no need to depend on MEMORY_HOTPLUG, as initialization code
> >> does not really use hotplug memory functionality. So, we can remove this
> >> requirement as well.
> >>
> >> This patch allows to use deferred struct page initialization on all
> >> platforms with memblock allocator.
> >>
> >> Tested on x86, arm64, and sparc. Also, verified that code compiles on
> >> PPC with CONFIG_MEMORY_HOTPLUG disabled.
> >
> > There is slight risk that we will encounter corner cases on some
> > architectures with weird memory layout/topology
>
> Which x86_32-pae seems to be. Many bad page state errors are emitted
> during boot when this patch is applied:

Hi Jiri,

Thank you for reporting this bug.

Because 32-bit systems are limited in the maximum amount of physical
memory, they don't need deferred struct pages. So, we can add depends
on 64BIT to DEFERRED_STRUCT_PAGE_INIT in mm/Kconfig.

However, before we do this, I want to try reproducing this problem and
root cause it, as it might expose a general problem that is not 32-bit
specific.

Thank you,
Pavel
