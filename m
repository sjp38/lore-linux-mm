Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9FE266B0007
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 13:48:46 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id n66-v6so2054972itg.0
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 10:48:46 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id s21-v6si6645517iog.180.2018.06.29.10.48.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 10:48:45 -0700 (PDT)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w5THmiPV062120
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 17:48:44 GMT
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp2130.oracle.com with ESMTP id 2jum587d39-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 17:48:44 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w5THmh1t016072
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 17:48:43 GMT
Received: from abhmp0016.oracle.com (abhmp0016.oracle.com [141.146.116.22])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w5THmhaE030181
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 17:48:43 GMT
Received: by mail-oi0-f44.google.com with SMTP id k81-v6so9181292oib.4
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 10:48:43 -0700 (PDT)
MIME-Version: 1.0
References: <20180627013116.12411-1-bhe@redhat.com> <20180627013116.12411-5-bhe@redhat.com>
 <cb67381c-078c-62e6-e4c0-9ecf3de9e84d@intel.com>
In-Reply-To: <cb67381c-078c-62e6-e4c0-9ecf3de9e84d@intel.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Fri, 29 Jun 2018 13:48:06 -0400
Message-ID: <CAGM2rebsL_fS8XKRvN34NWiFN3Hh63ZOD8jDj8qeSOUPXcZ2fA@mail.gmail.com>
Subject: Re: [PATCH v5 4/4] mm/sparse: Optimize memmap allocation during sparse_init()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@intel.com
Cc: bhe@redhat.com, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, pagupta@redhat.com, Linux Memory Management List <linux-mm@kvack.org>, kirill.shutemov@linux.intel.com

> > +      * increase 'nr_consumed_maps' whether its allocation of memmap
> > +      * or usemap failed or not, so that after we handle the i-th
> > +      * memory section, can get memmap and usemap of (i+1)-th section
> > +      * correctly. */
>
> This makes no sense to me.  Why are we incrementing 'nr_consumed_maps'
> when we do not consume one?
>
> You say that we increment it so that things will work, but not how or
> why it makes things work.  I'm confused.

Hi Dave,

nr_consumed_maps is a local counter. map_map contains struct pages for
each section. In order to assign them to correct sections this local
counter must be incremented even when some parts of map_map are empty.

Here is example:
Node1:
map_map[0] -> Struct pages ...
map_map[1] -> NULL
Node2:
map_map[2] -> Struct pages ...

We always want to configure section from Node2 with struct pages from
Node2. Even, if there are holes in-between. The same with usemap.

Pavel
