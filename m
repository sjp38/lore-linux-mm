Date: Mon, 25 Mar 2002 20:00:31 -0800 (PST)
Message-Id: <20020325.200031.118818331.davem@redhat.com>
Subject: Re: [patch] mmap bug with drivers that adjust vm_start
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20020325230046.A14421@redhat.com>
References: <20020325230046.A14421@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: bcrl@redhat.com
Cc: andrea@suse.de, marcelo@conectiva.com.br, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

   The patch below fixes a problem whereby a vma which has its vm_start 
   address changed by the file's mmap operation can result in the vma 
   being inserted into the wrong location within the vma tree.  This 
   results in page faults not being handled correctly leading to SEGVs, 
   as well as various BUG()s hitting on exit of the mm.  The fix is to 
   recalculate the insertion point when we know the address has changed.  
   Comments?  Patch is against 2.4.19-pre4.

Good catch.  Most of the time this happened to work because the driver
filled in the page tables completely (as is the case for most video
etc. drivers which use {io_,}remap_page_range et al..)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
