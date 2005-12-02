Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jB2NkZkQ004392
	for <linux-mm@kvack.org>; Fri, 2 Dec 2005 18:46:35 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jB2Njxf6099244
	for <linux-mm@kvack.org>; Fri, 2 Dec 2005 16:46:00 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jB2NkYuF028565
	for <linux-mm@kvack.org>; Fri, 2 Dec 2005 16:46:34 -0700
Subject: Re: Better pagecache statistics ?
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20051202224645.GB6576@redhat.com>
References: <20051201152029.GA14499@dmt.cnet>
	 <1133452790.27824.117.camel@localhost.localdomain>
	 <1133453411.2853.67.camel@laptopd505.fenrus.org>
	 <20051201170850.GA16235@dmt.cnet>
	 <1133457315.21429.29.camel@localhost.localdomain>
	 <1133457700.2853.78.camel@laptopd505.fenrus.org>
	 <20051201175711.GA17169@dmt.cnet>
	 <1133461212.21429.49.camel@localhost.localdomain>
	 <y0md5kfxi15.fsf@tooth.toronto.redhat.com>
	 <1133562716.21429.103.camel@localhost.localdomain>
	 <20051202224645.GB6576@redhat.com>
Content-Type: multipart/mixed; boundary="=-Ue3aRS0grugHplt1kGsK"
Date: Fri, 02 Dec 2005 15:46:46 -0800
Message-Id: <1133567206.21429.117.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Frank Ch. Eigler" <fche@redhat.com>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Arjan van de Ven <arjan@infradead.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--=-Ue3aRS0grugHplt1kGsK
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, 2005-12-02 at 17:46 -0500, Frank Ch. Eigler wrote:
> Hi -
> 
> On Fri, Dec 02, 2005 at 02:31:56PM -0800, Badari Pulavarty wrote:
> > On Fri, 2005-12-02 at 17:15 -0500, Frank Ch. Eigler wrote:
> > [...]
> > > #! stap
> > > probe kernel.function("add_to_page_cache") {
> > >   printf("pid %d added pages (%d)\n", pid(), $mapping->nrpages)
> > > }
> > > probe kernel.function("__remove_from_page_cache") {
> > >   printf("pid %d removed pages (%d)\n", pid(), $page->mapping->nrpages)
> > > }
> >
> > [...]  Having by "pid" basis is not good enough. I need per
> > file/mapping basis collected and sent to user-space on-demand.
> 
> If you can characterize all your data needs in terms of points to
> insert hooks (breakpoint addresses) and expressions to sample there,
> systemtap scripts can probably track the relationships.  (We have
> associative arrays, looping, etc.)
> 
> > Is systemtap hooked to relayfs to send data across to user-land ?
> > printf() is not an option.
> 
> systemtap can optionally use relayfs.  The printf you see here does
> not relate to/invoke the kernel printk, if that's what you're worried
> about.

Hmm. You are right.

Is there a way another user-level program/utility access some of the
data maintained in those arrays ?

> 
> > And also, I need to have this probe, installed from the boot time
> > and collecting all the information - so I can access it when I need
> > it
> 
> We haven't done much work yet to address on-demand kind of interaction
> with a systemtap probe session.  However, one could fake it by
> associating data-printing operations with events that are triggered
> purposely from userspace, like running a particular system call from a
> particularly named process.
> 
> > which means this bloats kernel memory. [...]
> 
> The degree of bloat is under the operator's control: systemtap only
> uses initialization-time memory allocation, so its arrays can fill up.

Does this mean that I can do something like

	page_cache[0xffff8100c4c6b298] = $mapping->nrpages ?

And this won't generate bloated arrays ?

Here is what I wrote earlier to capture some of the pagecache data.
Unfortunately, I can't capture whatever happend before inserting the
problem. So it won't give me information about all whats there in the
pagecache.

BTW, if you prefer - we can move the discussion to systemtap.
(I have few questions/issues on ret probes & accessability of
arguments - since I want to do this on return).

Thanks,
Badari





--=-Ue3aRS0grugHplt1kGsK
Content-Disposition: attachment; filename=pagecache.stp
Content-Type: text/plain; name=pagecache.stp; charset=utf-8
Content-Transfer-Encoding: 7bit

#! stap

global page_cache_pages

function _(n) { return string(n) } 

probe kernel.function("add_to_page_cache") {
	page_cache_pages[$mapping] = $mapping->nrpages
}

probe kernel.function("__remove_from_page_cache") {
	page_cache_pages[$page->mapping] = $page->mapping->nrpages
}

function report () {
  foreach (mapping in page_cache_pages) {
	print("mapping = " . hexstring(mapping) . 
		" nrpages = " . _(page_cache_pages[mapping]) . "\n")
  }
  delete page_cache_pages
}

probe end {
  report()
}

--=-Ue3aRS0grugHplt1kGsK--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
