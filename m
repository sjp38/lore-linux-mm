Message-ID: <48726158.9010308@linux-foundation.org>
Date: Mon, 07 Jul 2008 13:32:56 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH] Make CONFIG_MIGRATION available for s390
References: <1215354957.9842.19.camel@localhost.localdomain>	 <4872319B.9040809@linux-foundation.org>	 <1215451689.8431.80.camel@localhost.localdomain>	 <48725480.1060808@linux-foundation.org> <1215455148.8431.108.camel@localhost.localdomain>
In-Reply-To: <1215455148.8431.108.camel@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasunori Goto <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

Gerald Schaefer wrote:
> On Mon, 2008-07-07 at 12:38 -0500, Christoph Lameter wrote:
>> How does the compile break? It may be better to fix this where the function
>> is used.
> 
> Good point, I did not look into this deep enough and tried to fix the
> symptoms instead of the cause. There are two locations where the compile
> breaks:
> - mm/migrate.c: migrate_vmas() does not know vm_ops->migrate()

I think you just need to move the #endif from before migrate_vmas to the end (as you already suggested). Then migrate_vmas will no longer be compiled for the NUMA case. migrate_vmas() was added later and was not placed correctly it seems.


> - inlcude/linux/migrate.h: vma_migratable() does not know policy_zone

Again here you would have to add a new function.

vma_policy_migratable() should only be available for CONFIG_NUMA.

vma_migratable (without policy_zone check!) should be available if CONFIG_MIGRATION is on.
Not sure if we need such a test. If not then just make sure that vma_migratable() is
not included for the !NUMA case.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
