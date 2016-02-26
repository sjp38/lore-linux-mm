Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id B22386B0253
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 01:17:56 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fl4so45672336pad.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 22:17:56 -0800 (PST)
Received: from mail-pf0-x22e.google.com (mail-pf0-x22e.google.com. [2607:f8b0:400e:c00::22e])
        by mx.google.com with ESMTPS id uj7si17650812pab.111.2016.02.25.22.17.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 22:17:56 -0800 (PST)
Received: by mail-pf0-x22e.google.com with SMTP id q63so46536066pfb.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 22:17:55 -0800 (PST)
Date: Thu, 25 Feb 2016 22:17:46 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC v5 0/3] mm: make swapin readahead to gain more thp
 performance
In-Reply-To: <20160225233017.GA14587@debian>
Message-ID: <alpine.LSU.2.11.1602252151030.9793@eggly.anvils>
References: <1442259105-4420-1-git-send-email-ebru.akagunduz@gmail.com> <20150914144106.ee205c3ae3f4ec0e5202c9fe@linux-foundation.org> <alpine.LSU.2.11.1602242301040.6947@eggly.anvils> <1456439750.15821.97.camel@redhat.com> <20160225233017.GA14587@debian>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="0-578050751-1456467474=:9793"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, riel@redhat.com, hughd@google.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--0-578050751-1456467474=:9793
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Fri, 26 Feb 2016, Ebru Akagunduz wrote:
> in Thu, Feb 25, 2016 at 05:35:50PM -0500, Rik van Riel wrote:
> > On Wed, 2016-02-24 at 23:36 -0800, Hugh Dickins wrote:
> > >=A0
> > > Doesn't this imply that __collapse_huge_page_swapin() will initiate
> > > all
> > > the necessary swapins for a THP, then (given the
> > > FAULT_FLAG_ALLOW_RETRY)
> > > not wait for them to complete, so khugepaged will give up on that
> > > extent
> > > and move on to another; then after another full circuit of all the
> > > mms
> > > it needs to examine, it will arrive back at this extent and build a
> > > THP
> > > from the swapins it arranged last time.
> > >=20
> > > Which may work well when a system transitions from busy+swappingout
> > > to idle+swappingin, but isn't that rather a special case?=A0 It feels
> > > (meaning, I've not measured at all) as if the inbetween busyish case
> > > will waste a lot of I/O and memory on swapins that have to be
> > > discarded
> > > again before khugepaged has made its sedate way back to slotting them
> > > in.
> > >=A0
> >=20
> > There may be a fairly simple way to prevent
> > that from becoming an issue.
> >=20
> > When khugepaged wakes up, it can check the
> > PGSWPOUT or even the PGSTEAL_* stats for
> > the system, and skip swapin readahead if
> > there was swapout activity (or any page
> > reclaim activity?) since the time it last
> > ran.
> >=20
> > That way the swapin readahead will do
> > its thing when transitioning from
> > busy + swapout to idle + swapin, but not
> > while the system is under permanent memory
> > pressure.
> >=20
> The idea make sense for me.

Yes, it does sound a promising approach: please give it a try.

> > Am I forgetting anything obvious?
> >=20
> > Is this too aggressive?
> >=20
> > Not aggressive enough?
> >=20
> > Could PGPGOUT + PGSWPOUT be a useful
> > in-between between just PGSWPOUT or
> > PGSTEAL_*?

I've no idea offhand, would have to study what each of those
actually means: I'm really not familiar with them myself.

I did wonder whether to suggest using swapin_readahead_hits
instead, but there's probably several reasons why that would
be a bad idea (its volatility, its intent for a different and
private purpose, and perhaps an inappropriate feedback effect -
the swap pages of a split THP are much more likely to be adjacent
than usually happens, so readahead probably pays off well for them,
which is good, but should not feed back into the decision).

There is also a question of where to position the test or tests:
allocating the THP, and allocating pages for swapin, will apply
their own pressure, in danger of generating swapout.

Hugh
--0-578050751-1456467474=:9793--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
