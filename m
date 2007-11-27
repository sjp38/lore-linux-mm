Received: by ro-out-1112.google.com with SMTP id p7so1445365roc
        for <linux-mm@kvack.org>; Mon, 26 Nov 2007 18:29:29 -0800 (PST)
Date: Tue, 27 Nov 2007 10:26:10 +0800
From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: [Patch](Resend) mm/sparse.c: Improve the error handling for
	sparse_add_one_section()
Message-ID: <20071127022609.GA4164@hacking>
Reply-To: WANG Cong <xiyou.wangcong@gmail.com>
References: <1195507022.27759.146.camel@localhost> <20071123055150.GA2488@hacking> <20071126191316.99CF.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071126191316.99CF.Y-GOTO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: WANG Cong <xiyou.wangcong@gmail.com>, Dave Hansen <haveblue@us.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 26, 2007 at 07:19:49PM +0900, Yasunori Goto wrote:
>Hi, Cong-san.
>
>>  	ms->section_mem_map |= SECTION_MARKED_PRESENT;
>>  
>>  	ret = sparse_init_one_section(ms, section_nr, memmap, usemap);
>>  
>>  out:
>>  	pgdat_resize_unlock(pgdat, &flags);
>> -	if (ret <= 0)
>> -		__kfree_section_memmap(memmap, nr_pages);
>> +
>>  	return ret;
>>  }
>>  #endif
>
>Hmm. When sparse_init_one_section() returns error, memmap and 
>usemap should be free.

Hi, Yasunori.

Thanks for your comments. Is the following one fine for you?

Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>

---

Index: linux-2.6/mm/sparse.c
===================================================================
--- linux-2.6.orig/mm/sparse.c
+++ linux-2.6/mm/sparse.c
@@ -391,9 +391,17 @@ int sparse_add_one_section(struct zone *
 	 * no locking for this, because it does its own
 	 * plus, it does a kmalloc
 	 */
-	sparse_index_init(section_nr, pgdat->node_id);
+	ret = sparse_index_init(section_nr, pgdat->node_id);
+	if (ret < 0)
+		return ret;
 	memmap = kmalloc_section_memmap(section_nr, pgdat->node_id, nr_pages);
+	if (!memmap)
+		return -ENOMEM;
 	usemap = __kmalloc_section_usemap();
+	if (!usemap) {
+		__kfree_section_memmap(memmap, nr_pages);
+		return -ENOMEM;
+	}
 
 	pgdat_resize_lock(pgdat, &flags);
 
@@ -403,10 +411,6 @@ int sparse_add_one_section(struct zone *
 		goto out;
 	}
 
-	if (!usemap) {
-		ret = -ENOMEM;
-		goto out;
-	}
 	ms->section_mem_map |= SECTION_MARKED_PRESENT;
 
 	ret = sparse_init_one_section(ms, section_nr, memmap, usemap);
@@ -414,7 +418,7 @@ int sparse_add_one_section(struct zone *
 out:
 	pgdat_resize_unlock(pgdat, &flags);
 	if (ret <= 0)
-		__kfree_section_memmap(memmap, nr_pages);
+		kfree(usemap);
 	return ret;
 }
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
