Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7C7F26B0292
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 13:28:53 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id o21so45871100qtb.13
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 10:28:53 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id j22si4265617qkh.63.2017.06.12.10.28.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jun 2017 10:28:52 -0700 (PDT)
Date: Mon, 12 Jun 2017 13:28:30 -0400
From: "Liam R. Howlett" <Liam.Howlett@Oracle.com>
Subject: Re: [PATCH] mm/hugetlb: Warn the user when issues arise on boot due
 to hugepages
Message-ID: <20170612172829.bzjfmm7navnobh4t@oracle.com>
References: <20170603005413.10380-1-Liam.Howlett@Oracle.com>
 <20170605045725.GA9248@dhcp22.suse.cz>
 <20170605151541.avidrotxpoiekoy5@oracle.com>
 <20170606054917.GA1189@dhcp22.suse.cz>
 <20170606060147.GB1189@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170606060147.GB1189@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mike.kravetz@Oracle.com, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, zhongjiang@huawei.com, aarcange@redhat.com, kirill.shutemov@linux.intel.com

* Michal Hocko <mhocko@suse.com> [170606 02:01]:
> On Tue 06-06-17 07:49:17, Michal Hocko wrote:
> > On Mon 05-06-17 11:15:41, Liam R. Howlett wrote:
> > > * Michal Hocko <mhocko@suse.com> [170605 00:57]:
> > > > On Fri 02-06-17 20:54:13, Liam R. Howlett wrote:
> > > > > When the user specifies too many hugepages or an invalid
> > > > > default_hugepagesz the communication to the user is implicit in the
> > > > > allocation message.  This patch adds a warning when the desired page
> > > > > count is not allocated and prints an error when the default_hugepagesz
> > > > > is invalid on boot.
> > > > 
> > > > We do not warn when doing echo $NUM > nr_hugepages, so why should we
> > > > behave any different during the boot?
> > > 
> > > During boot hugepages will allocate until there is a fraction of the
> > > hugepage size left.  That is, we allocate until either the request is
> > > satisfied or memory for the pages is exhausted.  When memory for the
> > > pages is exhausted, it will most likely lead to the system failing with
> > > the OOM manager not finding enough (or anything) to kill (unless you're
> > > using really big hugepages in the order of 100s of MB or in the GBs).
> > > The user will most likely see the OOM messages much later in the boot
> > > sequence than the implicitly stated message.  Worse yet, you may even
> > > get an OOM for each processor which causes many pages of OOMs on modern
> > > systems.  Although these messages will be printed earlier than the OOM
> > > messages, at least giving the user errors and warnings will highlight
> > > the configuration as an issue.  I'm trying to point the user in the
> > > right direction by providing a more robust statement of what is failing.
> > 
> > Well, an oom report will tell us how much memory is eaten by hugetlb so
> > you would get a clue that something is misconfigured.

Absolutely, however this is again implicitly telling the user why the
system is failing to boot.  A lot of time may be - and has been - spent
finding what went wrong, and by multiple users.

> 
> And just to be more clear. I do not _object_ to the warning I just
> _think_ it is not very useful actually. If somebody misconfigure so
> badly that hugetlb allocations fail during the boot then it will be
> very likely visible. But if somebody misconfigures slightly less to not
> fail the system is very likely to not work properly and there will be no
> warning that this might be the source of problems. So is it worth adding
> more code with that limited usefulness?

I think telling the user that something failed is very useful.  This
obviously does not cover off all failure cases as you have pointed out,
but it is certainly better than silently continuing as is the case
today.

Are you suggesting that the error message be provided if the failure
happens after boot as well?

Thanks,
Liam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
