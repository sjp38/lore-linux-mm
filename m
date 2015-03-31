Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 342366B0038
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 16:33:40 -0400 (EDT)
Received: by patj18 with SMTP id j18so30087677pat.2
        for <linux-mm@kvack.org>; Tue, 31 Mar 2015 13:33:39 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id gp2si20834912pbb.80.2015.03.31.13.33.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Mar 2015 13:33:39 -0700 (PDT)
Date: Tue, 31 Mar 2015 13:33:38 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: use PageAnon() and PageKsm() helpers in
 page_anon_vma()
Message-Id: <20150331133338.ed4ab6cc9a5ab6f6ad4301eb@linux-foundation.org>
In-Reply-To: <20150331143534.GA10808@node.dhcp.inet.fi>
References: <1427802647-16764-1-git-send-email-kirill.shutemov@linux.intel.com>
	<alpine.DEB.2.11.1503310810320.13959@gentwo.org>
	<20150331143534.GA10808@node.dhcp.inet.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Christoph Lameter <cl@linux.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Konstantin Khlebnikov <koct9i@gmail.com>, Rik van Riel <riel@redhat.com>

On Tue, 31 Mar 2015 17:35:34 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Tue, Mar 31, 2015 at 08:11:02AM -0500, Christoph Lameter wrote:
> > On Tue, 31 Mar 2015, Kirill A. Shutemov wrote:
> > 
> > > Let's use PageAnon() and PageKsm() helpers instead. It helps readability
> > > and makes page_anon_vma() work correctly on tail pages.
> > 
> > But it adds a branch due to the use of ||.
> 
> Which caller is hot enough to care?
> 

It's a surprisingly expensive patch.

   text    data     bss     dec     hex filename

  19984    1153   15192   36329    8de9 mm/ksm.o-before
  20028    1153   15216   36397    8e2d mm/ksm.o-after

  14728     116    5168   20012    4e2c mm/rmap.o-before
  14763     116    5192   20071    4e67 mm/rmap.o-after

  25723    1417    9776   36916    9034 mm/swapfile.o-before
  25769    1417    9800   36986    907a mm/swapfile.o-after

197 bytes more text+bss, 125 bytes more text.

(Why the heck do changes like this allegedly affect bss size?)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
