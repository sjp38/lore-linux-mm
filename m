From: Johannes Weiner <hannes@saeurebad.de>
Subject: [PATCH] Stay below upper pmd boundary on pte range walk
References: <47FC95AD.1070907@tiscali.nl> <87zls3qhop.fsf@saeurebad.de>
	<jer6dd9ajn.fsf@sykes.suse.de>
Date: Thu, 10 Apr 2008 16:01:49 +0200
In-Reply-To: <jer6dd9ajn.fsf@sykes.suse.de> (Andreas Schwab's message of "Thu,
	10 Apr 2008 14:09:00 +0200")
Message-ID: <878wzlzu42.fsf_-_@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andreas Schwab <schwab@suse.de>
Cc: Roel Kluin <12o3l@tiscali.nl>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Hi,

Andreas Schwab <schwab@suse.de> writes:

> Johannes Weiner <hannes@saeurebad.de> writes:
>
>>> Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
>>> ---
>>> diff --git a/mm/pagewalk.c b/mm/pagewalk.c
>>> index 1cf1417..6615f0b 100644
>>> --- a/mm/pagewalk.c
>>> +++ b/mm/pagewalk.c
>>> @@ -15,7 +15,7 @@ static int walk_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>>>  		       break;
>>>  	} while (pte++, addr += PAGE_SIZE, addr != end);
>>>  
>>> -	pte_unmap(pte);
>>> +	pte_unmap(pte - 1);
>>>  	return err;
>>>  }
>>
>> This does not make any sense to me.
>
> There is something fishy here.  If the loop ends because addr == end
> then pte has been incremented past the pmd page for addr, no?

Whoops, yes.  But Roel's fix breaks if the break is taken in the first
iteration of the loop, because the pte is then out of the lower bounds
of the pmd page.  Please see attached fix.

	Hannes

---

After the loop in walk_pte_range() pte might point to the first address
after the pmd it walks.  The pte_unmap() is then applied to something
bad.

Spotted by Roel Kluin and Andreas Schwab.

Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
---

A bug is unlikely, though.  kunmap_atomic() looks up the kmap entry by
map-type instead of the address the pte points.  So the worst thing I
could find with a quick grep was that a wrong TLB entry is being
flushed.  Still, the code is wrong :)

diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index 1cf1417..cf3c004 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -13,7 +13,7 @@ static int walk_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 		err = walk->pte_entry(pte, addr, addr + PAGE_SIZE, private);
 		if (err)
 		       break;
-	} while (pte++, addr += PAGE_SIZE, addr != end);
+	} while (addr += PAGE_SIZE, addr != end && pte++);
 
 	pte_unmap(pte);
 	return err;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
