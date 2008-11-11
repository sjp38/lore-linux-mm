Date: Wed, 12 Nov 2008 00:25:13 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/4] Add replace_page(), change the mapping of pte from
	one page into another
Message-ID: <20081111232513.GS10818@random.random>
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com> <1226409701-14831-2-git-send-email-ieidus@redhat.com> <1226409701-14831-3-git-send-email-ieidus@redhat.com> <20081111114555.eb808843.akpm@linux-foundation.org> <20081111210655.GG10818@random.random> <Pine.LNX.4.64.0811111522150.27767@quilx.com> <20081111221753.GK10818@random.random> <Pine.LNX.4.64.0811111626520.29222@quilx.com> <20081111231722.GR10818@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081111231722.GR10818@random.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, chrisw@redhat.com, avi@redhat.com, izike@qumranet.com
List-ID: <linux-mm.kvack.org>

On Wed, Nov 12, 2008 at 12:17:22AM +0100, Andrea Arcangeli wrote:
> We don't have to check the page_count vs mapcount later in
> replace_page because we know if anybody started an O_DIRECT read from
> disk, it would have triggered a cow, and the pte_same check that we
> have to do for other reasons would take care of bailing out the
> replace_page.

Ah, for completeness: above I didn't mention the case of O_DIRECT
writes to disk, because we never need to care about those. They're
never a problem. If the page is replaced and the cpu writes to the
page and by doing so triggers a cow that lead to the CPU write to go
in a different page (not the one under dma) it'll be like if the write
to disk completed before the cpu overwritten the page, so result is
undefined. I don't think we've to define the case of somebody doing a
direct read from a location where there's still an o_direct write in
flight either.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
