Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 12F1F6B0007
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 08:12:44 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id y18-v6so6447755itc.2
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 05:12:44 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 77-v6si4545186jap.32.2018.06.28.05.12.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jun 2018 05:12:43 -0700 (PDT)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w5SC3s0r149564
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 12:12:42 GMT
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp2130.oracle.com with ESMTP id 2jum58202n-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 12:12:42 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w5SCCfIU029084
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 12:12:41 GMT
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w5SCCfhT004123
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 12:12:41 GMT
Received: by mail-oi0-f46.google.com with SMTP id k81-v6so4941448oib.4
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 05:12:41 -0700 (PDT)
MIME-Version: 1.0
References: <20180628062857.29658-1-bhe@redhat.com> <20180628062857.29658-5-bhe@redhat.com>
 <20180628120937.GC12956@techadventures.net>
In-Reply-To: <20180628120937.GC12956@techadventures.net>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Thu, 28 Jun 2018 08:12:04 -0400
Message-ID: <CAGM2reZsZVhhg2=dQZf6D-NmPTFRN-_95+s61pC7Axz5G5mkMQ@mail.gmail.com>
Subject: Re: [PATCH v6 4/5] mm/sparse: Optimize memmap allocation during sparse_init()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: bhe@redhat.com, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, dave.hansen@intel.com, pagupta@redhat.com, Linux Memory Management List <linux-mm@kvack.org>, kirill.shutemov@linux.intel.com

> > +             if (nr_consumed_maps >= nr_present_sections) {
> > +                     pr_err("nr_consumed_maps goes beyond nr_present_sections\n");
> > +                     break;
> > +             }
>
> Hi Baoquan,
>
> I am sure I am missing something here, but is this check really needed?
>
> I mean, for_each_present_section_nr() only returns the section nr if the section
> has been marked as SECTION_MARKED_PRESENT.
> That happens in memory_present(), where now we also increment nr_present_sections whenever
> we find a present section.
>
> So, for_each_present_section_nr() should return the same nr of section as nr_present_sections.
> Since we only increment nr_consumed_maps once in the loop, I am not so sure we can
> go beyond nr_present_sections.
>
> Did I overlook something?

You did not, this is basically a safety check. A BUG_ON() would be
better here. As, this something that should really not happening, and
would mean a bug in the current project.
