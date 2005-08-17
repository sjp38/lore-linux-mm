Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j7HJf67o015620
	for <linux-mm@kvack.org>; Wed, 17 Aug 2005 15:41:06 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j7HJf6Kl291746
	for <linux-mm@kvack.org>; Wed, 17 Aug 2005 15:41:06 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j7HJf6Pg000577
	for <linux-mm@kvack.org>; Wed, 17 Aug 2005 15:41:06 -0400
Subject: Re: [PATCH 3/4] x86-walk-check
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1124305469.3139.43.camel@localhost.localdomain>
References: <1124304966.3139.37.camel@localhost.localdomain>
	 <1124305469.3139.43.camel@localhost.localdomain>
Content-Type: text/plain
Date: Wed, 17 Aug 2005 12:41:02 -0700
Message-Id: <1124307662.5879.37.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, christoph@lameter.com, ak@suse.de, kenneth.w.chen@intel.com, david@gibson.dropbear.id.au
List-ID: <linux-mm.kvack.org>

On Wed, 2005-08-17 at 14:04 -0500, Adam Litke wrote:
> 
> +       if (pgd_present(*pgd)) {
> +               pud = pud_offset(pgd, addr);
> +               if (pud_present(*pud)) {
> +                       pmd = pmd_offset(pud, addr);
> +               }
> +       }

You can probably kill that extra set of braces on the indented if().

Or, do something like this (which I think is a little bit more
consistent with a lot of other code.

-       pud = pud_offset(pgd, addr);
-       pmd = pmd_offset(pud, addr);
+       if (!pgd_present(*pgd))
+		goto out;
+
+       pud = pud_offset(pgd, addr);
+       if (pud_present(*pud))
+       	pmd = pmd_offset(pud, addr);
+
+out:
        return (pte_t *) pmd;

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
