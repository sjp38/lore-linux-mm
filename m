Subject: Re: [patch 2/3] only allow nonlinear vmas for ram backed
	filesystems
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070325160050.fe7cb284.akpm@linux-foundation.org>
References: <E1HVEOB-0006fX-00@dorka.pomaz.szeredi.hu>
	 <E1HVEQJ-0006gF-00@dorka.pomaz.szeredi.hu>
	 <20070325160050.fe7cb284.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Mon, 26 Mar 2007 08:57:41 +0200
Message-Id: <1174892261.6792.9.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 2007-03-25 at 16:00 -0800, Andrew Morton wrote:
> On Sat, 24 Mar 2007 23:09:19 +0100 Miklos Szeredi <miklos@szeredi.hu> wrote:
> 
> > Dirty page accounting/limiting doesn't work for nonlinear mappings,
> 
> Doesn't it?  iirc the problem is that we don't correctly re-clean the ptes
> while starting writeout.  And the dirty-page accounting is in fact correct
> (it'd darn well better be).

If we do not re-protect the pages on writeout, we'll decrement the dirty
count but not get a fault on re-dirty. Hence the dirty count will
actually skew.

In order to make page_mkclean() work for nonlinear vmas we need to do a
full pte scan for each invocation (we could perhaps only scan 1 in n
times to try and limit the damage) and that hurts. This will basically
render it useless.

The other solution is adding rmap information to nonlinear vmas but
doubling the memory overhead for nonlinear mappings was not deemed a
good idea.

> > so
> > for non-ram backed filesystems emulate with linear mappings.  This
> > retains ABI compatibility with previous kernels at minimal code cost.
> > 
> > All known users of nonlinear mappings actually use tmpfs, so this
> > shouldn't have any negative effect.
> 
> Unless someone is using remap_file_pages() against an ext3 file, in which
> case their application stops working?

it'll work up to a certain point (when you hit the max vma count). When
this issue first came up a few weeks ago, nobody knew of any non tmpfs
users.

> That would be a problem.  These guys:
> http://www.technovelty.org/code/linux/fremap.html, for example, will be in
> for a little surprise.

Its an example, it doesn't show if there are actually users of this, but
point taken. We actually could make this very example work by noting
that they map PROT_READ only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
