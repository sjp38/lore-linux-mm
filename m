Date: Mon, 9 Feb 2004 15:58:23 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.3-rc1-mm1
Message-Id: <20040209155823.6f884f23.akpm@osdl.org>
In-Reply-To: <20040209151818.32965df6@philou.gramoulle.local>
References: <20040209014035.251b26d1.akpm@osdl.org>
	<20040209151818.32965df6@philou.gramoulle.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Philippe =?ISO-8859-1?Q?Gramoull=E9?= <philippe.gramoulle@mmania.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Philippe Gramoulle  <philippe.gramoulle@mmania.com> wrote:
>
> Starting with 2.6.3-rc1-mm1, nfsd isn't working any more. Exportfs just hangs.

Yes, sorry.  The nfsd patches had a painful birth.  This chunk got lost.

--- 25/net/sunrpc/svcauth.c~nfsd-02-sunrpc-cache-init-fixes	Mon Feb  9 14:04:03 2004
+++ 25-akpm/net/sunrpc/svcauth.c	Mon Feb  9 14:06:26 2004
@@ -150,7 +150,13 @@ DefineCacheLookup(struct auth_domain,
 		  &auth_domain_cache,
 		  auth_domain_hash(item),
 		  auth_domain_match(tmp, item),
-		  kfree(new); if(!set) return NULL;
+		  kfree(new); if(!set) {
+			if (new)
+				write_unlock(&auth_domain_cache.hash_lock);
+			else
+				read_unlock(&auth_domain_cache.hash_lock);
+			return NULL;
+		  }
 		  new=item; atomic_inc(&new->h.refcnt),
 		  /* no update */,
 		  0 /* no inplace updates */

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
