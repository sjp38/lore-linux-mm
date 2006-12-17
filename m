From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] Fix sparsemem on Cell
Date: Mon, 18 Dec 2006 00:02:09 +0100
References: <20061215171411.E3EE01AD@localhost.localdomain>
In-Reply-To: <20061215171411.E3EE01AD@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Message-Id: <200612180002.11079.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linuxppc-dev@ozlabs.org
Cc: Dave Hansen <haveblue@us.ibm.com>, cbe-oss-dev@ozlabs.org, akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hch@infradead.org, paulus@samba.org, mkravetz@us.ibm.com, gone@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Friday 15 December 2006 18:14, Dave Hansen wrote:
> +       if (system_state >= SYSTEM_RUNNING)
> +               return 1;
> +       if (!early_pfn_valid(pfn))
> +               return 0;
> +       if (!early_pfn_in_nid(pfn, nid))
> +               return 0;

I haven't tried it, but I assume this is still wrong. On cell,
we didn't actually hit the case where the init sections have
been overwritten, since we call __add_pages from an initcall.

However, the pages we add are not part of the early_node_map,
so early_pfn_in_nid() returns a bogus result, causing some
page structs not to get initialized. I believe your patch
is going in the right direction, but it does not solve the
bug we have...

	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
