Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABA00C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 08:44:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F59D20854
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 08:44:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="H2yafXhC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F59D20854
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F40EB6B0007; Tue, 19 Mar 2019 04:44:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EEFA06B0008; Tue, 19 Mar 2019 04:44:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE01E6B000A; Tue, 19 Mar 2019 04:44:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9B7706B0007
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 04:44:46 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id i13so21699709pgb.14
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 01:44:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=qAR3a4Tp536S5BF0fcnDXo7BSqIJ+Wix2hz2G88QfYw=;
        b=KfY0u8kgfcuJ7IFZuNaMjzcBLz9g7fc9GscKaqgqkHlfGljCPaf6SzaSUtwKZEOttd
         5qVRY16OvPZrm4zj9jUqTxzd4hdtoSY9mwJ2WARQv5R6FqKxx8OErOIyf5G/0aaB43LR
         /CphAzg1Hzde1E5F2f/7JfyV1EElFnG0JtO4hgmLm0rWJvDcdKySqSOeBrv70ppks/G8
         ft0YWT3skhBzOzUsgqNoGyvReOUzQrR4xx4WL5cB81NcBu1Tnv0Grf82oXxF0PmoRzK1
         WGZwKBh8+CpaRdI35UIihEb9ew1JuZFetBLOUB5/OWkxXYtvNEsRum+Vrssy3t7NT0J8
         8fLA==
X-Gm-Message-State: APjAAAWShtBHdtzUT3rbsB0tf0gv76Nbjk1ArWEncB1YrqHDV2DPucim
	Sy7mAr89I8pPse4FxNhWRjvHShRRYytu5e21VmJ5dWWpYpXonipl/Xq+A9f8GNYo/oRy5Vk3479
	SGMn7e0nMK3NS/xhOWTCdnP6q1KN/Ny1p35V5eSSXph69FJAvuK9bjGMGtvzGr7T8gg==
X-Received: by 2002:a65:63d9:: with SMTP id n25mr759128pgv.243.1552985086191;
        Tue, 19 Mar 2019 01:44:46 -0700 (PDT)
X-Received: by 2002:a65:63d9:: with SMTP id n25mr759062pgv.243.1552985085056;
        Tue, 19 Mar 2019 01:44:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552985085; cv=none;
        d=google.com; s=arc-20160816;
        b=puOGV9XSk/Pvay9P16X3odspPKRlNf6EDqrt95StLOqvACi+zyqTOhGbdv8nGdm7Fi
         Cjrt2jdDQ5QYiGo2q9PgbSzfbkfAY6mJwLl3e21chV84F1L+e5nO/RlwQlAp0c4ZSq4z
         MnfXTKG5ZuxNfkwVYcArS3mOt5fss77N82muBCMf0heAdgr4/pqqgf8j0cpsNpO0FF8m
         c7CTeqXu+vbeJgnb9dHRuEYG94wMtX7PSoK8VKRMmKdFv0lne5wFM1gTEt3We5UJEsdx
         rzgFNgY9NHuM0UoEHnhGQaoxWJCBjw6WyvUkpfVi80RWgVymQkpw8xp2n9rMh09hlbLG
         SliA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=qAR3a4Tp536S5BF0fcnDXo7BSqIJ+Wix2hz2G88QfYw=;
        b=k/NmlcEaqLvobExumOmWyOjpb7wIuqRGCNSdyJK29QHHCV1XedJ+Ruq87pKie37Xn3
         3qYrQ/Pju7xllG3yjwJZ5ICG9YYYt4LS/OXbKnAXdJF15DIejy0/syGknPSeUsKgKslD
         l23gTj/x5hur0Na23TNaY5O0wPCalOjl3xu7lnsaZ4SjBxuAtqFaHO26GqTAu7l9UfLU
         sqicrDyic+YExQCSyFd3VbltHszRS2UL8svOs187XhUUwrW9QK+Z0Xed6TTKKlU9xPX9
         s05emjl01PCulzbcauWRzmsCe89NPcvK56CFuo3iCfXTRS9pv3UECDDg5iGLbY+hJYwk
         Puqg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=H2yafXhC;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k29sor8477781pgb.60.2019.03.19.01.44.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 01:44:44 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=H2yafXhC;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=qAR3a4Tp536S5BF0fcnDXo7BSqIJ+Wix2hz2G88QfYw=;
        b=H2yafXhCxww2Ui/9GWn4Ibv+5222qc24hBAoz7mopK6XBNEl8YsyIGoBL4mxVsgNv1
         GBLIgNc751rNEJNNZENFQqArXrc9hT/wJVJv9horcQyoLACuk68xKiqmJDy1NxWUxFva
         VQbtkyhDQ4rS0v3TVhd+NS2TH8HT5XPiJmO2JYXNLOncoVFhe9x//OOexFxs4/jcGHdm
         Xa15eF/S8SUSaWh1XHCQoRMwCEd1gqxIO8goZoHmaDIwUbJwUiyxWSZgNnfgofVsrtIV
         b2YcyuElYoq66Y/1fXxI3tZGT0u+gr9rRYiYlBRKIlW2MHnJDFRhsVBxbVMxnjBFoexi
         O4Sw==
X-Google-Smtp-Source: APXvYqwQJhhbuKxbG07ohl6GTw3nbB9v8fuYg7I4XK9bC/v/Mt1y46+7YdnuVQi/DtVjy6lZCh0v3A==
X-Received: by 2002:a63:f905:: with SMTP id h5mr723037pgi.223.1552985084044;
        Tue, 19 Mar 2019 01:44:44 -0700 (PDT)
Received: from kshutemo-mobl1.localdomain ([192.55.54.45])
        by smtp.gmail.com with ESMTPSA id g188sm23542592pfc.24.2019.03.19.01.44.42
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 01:44:43 -0700 (PDT)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id 5C088300B98; Tue, 19 Mar 2019 11:44:39 +0300 (+03)
Date: Tue, 19 Mar 2019 11:44:39 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Michal =?utf-8?B?U3VjaMOhbmVr?= <msuchanek@suse.de>,
	Oliver <oohall@gmail.com>, Jan Kara <jack@suse.cz>,
	linux-nvdimm <linux-nvdimm@lists.01.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>, Ross Zwisler <zwisler@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 2/2] mm/dax: Don't enable huge dax mapping by default
Message-ID: <20190319084439.eya2pisiirattuil@kshutemo-mobl1>
References: <20190228083522.8189-1-aneesh.kumar@linux.ibm.com>
 <20190228083522.8189-2-aneesh.kumar@linux.ibm.com>
 <CAOSf1CHjkyX2NTex7dc1AEHXSDcWA_UGYX8NoSyHpb5s_RkwXQ@mail.gmail.com>
 <CAPcyv4jhEvijybSVsy+wmvgqfvyxfePQ3PUqy1hhmVmPtJTyqQ@mail.gmail.com>
 <87k1hc8iqa.fsf@linux.ibm.com>
 <20190306124453.126d36d8@naga.suse.cz>
 <df01bf6e-84a1-53fb-bf0c-0957af2f79e1@linux.ibm.com>
 <CAPcyv4iLm09DSiF3niFprP3PTFrgB5pZPp9AysBpRa-m725tmw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4iLm09DSiF3niFprP3PTFrgB5pZPp9AysBpRa-m725tmw@mail.gmail.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 09:07:13AM -0700, Dan Williams wrote:
> On Wed, Mar 6, 2019 at 4:46 AM Aneesh Kumar K.V
> <aneesh.kumar@linux.ibm.com> wrote:
> >
> > On 3/6/19 5:14 PM, Michal Suchánek wrote:
> > > On Wed, 06 Mar 2019 14:47:33 +0530
> > > "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> wrote:
> > >
> > >> Dan Williams <dan.j.williams@intel.com> writes:
> > >>
> > >>> On Thu, Feb 28, 2019 at 1:40 AM Oliver <oohall@gmail.com> wrote:
> > >>>>
> > >>>> On Thu, Feb 28, 2019 at 7:35 PM Aneesh Kumar K.V
> > >>>> <aneesh.kumar@linux.ibm.com> wrote:
> > >
> > >> Also even if the user decided to not use THP, by
> > >> echo "never" > transparent_hugepage/enabled , we should continue to map
> > >> dax fault using huge page on platforms that can support huge pages.
> > >
> > > Is this a good idea?
> > >
> > > This knob is there for a reason. In some situations having huge pages
> > > can severely impact performance of the system (due to host-guest
> > > interaction or whatever) and the ability to really turn off all THP
> > > would be important in those cases, right?
> > >
> >
> > My understanding was that is not true for dax pages? These are not
> > regular memory that got allocated. They are allocated out of /dev/dax/
> > or /dev/pmem*. Do we have a reason not to use hugepages for mapping
> > pages in that case?
> 
> The problem with the transparent_hugepage/enabled interface is that it
> conflates performing compaction work to produce THP-pages with the
> ability to map huge pages at all.

That's not [entirely] true. transparent_hugepage/defrag gates heavy-duty
compaction. We do only very limited compaction if it's not advised by
transparent_hugepage/defrag.

I believe DAX has to respect transparent_hugepage/enabled. Or not
advertise its huge pages as THP. It's confusing for user.

-- 
 Kirill A. Shutemov

