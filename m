From: Christoph Lameter <clameter@sgi.com>
Subject: [ofa-general] Re: [PATCH 2 of 8] Moves all mmu notifier methods
 outside the PT lock (first and not last
Date: Wed, 2 Apr 2008 15:03:12 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0804021459560.31247@schroedinger.engr.sgi.com>
References: <fe00cb9deeb314673963.1207171803@duo.random>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <fe00cb9deeb314673963.1207171803@duo.random>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Izik Eidus <izike@qumranet.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, akpm@linux-foundation.org
List-Id: linux-mm.kvack.org

On Wed, 2 Apr 2008, Andrea Arcangeli wrote:

> diff --git a/mm/memory.c b/mm/memory.c
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1626,9 +1626,10 @@
>  			 */
>  			page_table = pte_offset_map_lock(mm, pmd, address,
>  							 &ptl);
> -			page_cache_release(old_page);
> +			new_page = NULL;
>  			if (!pte_same(*page_table, orig_pte))
>  				goto unlock;
> +			page_cache_release(old_page);
>  
>  			page_mkwrite = 1;
>  		}

This is deferring frees and not moving the callouts. KVM specific? What 
exactly is this doing?

A significant portion of this seems to be undoing what the first patch 
did.
