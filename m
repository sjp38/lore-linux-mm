Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 656D16B0009
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 03:28:00 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id u36so12756315wrf.21
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 00:28:00 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k47sor7642879eda.49.2018.03.06.00.27.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Mar 2018 00:27:59 -0800 (PST)
Date: Tue, 6 Mar 2018 11:27:43 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC, PATCH 13/22] mm, rmap: Free encrypted pages once mapcount
 drops to zero
Message-ID: <20180306082743.2epdfxv4ds7hz7py@node.shutemov.name>
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
 <20180305162610.37510-14-kirill.shutemov@linux.intel.com>
 <e04536bc-77e9-84d0-3c23-1dfea8542da5@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e04536bc-77e9-84d0-3c23-1dfea8542da5@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 05, 2018 at 11:13:36AM -0800, Dave Hansen wrote:
> On 03/05/2018 08:26 AM, Kirill A. Shutemov wrote:
> > @@ -1292,6 +1308,12 @@ static void page_remove_anon_compound_rmap(struct page *page)
> >  		__mod_node_page_state(page_pgdat(page), NR_ANON_MAPPED, -nr);
> >  		deferred_split_huge_page(page);
> >  	}
> > +
> > +	anon_vma = page_anon_vma(page);
> > +	if (anon_vma_encrypted(anon_vma)) {
> > +		int keyid = anon_vma_keyid(anon_vma);
> > +		free_encrypt_page(page, keyid, compound_order(page));
> > +	}
> >  }
> 
> It's not covered in the description and I'm to lazy to dig into it, so:
> Without this code, where do they get freed?  Why does it not cause any
> problems to free them here?

It's the only place where we get it freed. "Freeing" is not the best
terminology here, but I failed to come up with something batter.
We prepare the encryption page to being freed: flush the cache in MKTME
case.

The page itself gets freed later in a usual manner: once refcount drops to
zero. The problem is that we may not have valid anon_vma around once
mapcount drops to zero, so we have to do "freeing" here.

For anonymous memory once mapcount dropped to zero there's no way it will
get mapped back to userspace. page_remove_anon

Kernel still will be able to access the page with kmap() and I will need
to be very careful to get it right wrt cache management.

I'll update the description.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
