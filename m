Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id OAA05766
	for <linux-mm@kvack.org>; Mon, 3 Mar 2003 14:19:06 -0800 (PST)
Date: Mon, 3 Mar 2003 14:15:18 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [PATCH 2.5.63] Teach page_mapped about the anon flag
Message-Id: <20030303141518.12d9ccd8.akpm@digeo.com>
In-Reply-To: <117290000.1046728362@baldur.austin.ibm.com>
References: <20030227025900.1205425a.akpm@digeo.com>
	<200302280822.09409.kernel@kolivas.org>
	<20030227134403.776bf2e3.akpm@digeo.com>
	<118810000.1046383273@baldur.austin.ibm.com>
	<20030227142450.1c6a6b72.akpm@digeo.com>
	<103400000.1046725581@baldur.austin.ibm.com>
	<20030303131210.36645af6.akpm@digeo.com>
	<107610000.1046726685@baldur.austin.ibm.com>
	<20030303133539.6594e0b6.akpm@digeo.com>
	<117290000.1046728362@baldur.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dave McCracken <dmccr@us.ibm.com> wrote:
>
> 
> --On Monday, March 03, 2003 13:35:39 -0800 Andrew Morton <akpm@digeo.com>
> wrote:
> 
> > We do need a patch I think.  page_mapped() is still assuming that an
> > all-bits-zero atomic_t corresponds to a zero-value atomic_t.
> > 
> > This does appear to be true for all supported architectures, but it's a
> > bit grubby.
> 
> If that's ever not true then we need extra code to initialize/rezero that
> field, since we assume it's zero on alloc, and the pte_chain code also
> assumes it's zero for a new page.

Well why not make mapcount an "int" and move the places where it is modified
inside pte_chain_lock()?

That does not increase the number of atomic operations, and it makes me stop
wondering if this:

                if (atomic_read(&page->pte.mapcount) == 0)
                        inc_page_state(nr_mapped);

is racy ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
