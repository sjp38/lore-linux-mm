Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 52AA36B007B
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 09:32:10 -0500 (EST)
Message-ID: <4B4DD8DB.8080900@suse.com>
Date: Wed, 13 Jan 2010 09:29:47 -0500
From: Jeff Mahoney <jeffm@suse.com>
MIME-Version: 1.0
Subject: Re: [patch 2/6] hugetlb: Fix section mismatches
References: <20100113004855.550486769@suse.com> <20100113004938.715904356@suse.com> <alpine.DEB.2.00.1001130127450.469@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1001130127450.469@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 01/13/2010 04:28 AM, David Rientjes wrote:
> On Tue, 12 Jan 2010, Jeff Mahoney wrote:
> 
>>  hugetlb_register_node calls hugetlb_sysfs_add_hstate, which is marked with
>>  __init. Since hugetlb_register_node is only called by
>>  hugetlb_register_all_nodes, which in turn is only called by hugetlb_init,
>>  it's safe to mark both of them as __init.
>>
>> Signed-off-by: Jeff Mahoney <jeffm@suse.com>
>> ---
>>  mm/hugetlb.c |    4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -1630,7 +1630,7 @@ void hugetlb_unregister_node(struct node
>>   * hugetlb module exit:  unregister hstate attributes from node sysdevs
>>   * that have them.
>>   */
>> -static void hugetlb_unregister_all_nodes(void)
>> +static void __init hugetlb_unregister_all_nodes(void)
>>  {
>>  	int nid;
>>  
> 
> This is wrong, you want to move hugetlb_register_all_nodes() to 
> .init.text, not hugetlb_unregister_all_nodes().

Yep. You're right. I had this correct in my initial version of the patch
but accidentally deleted it while renaming them. I'll re-send.

- -Jeff

>> @@ -1650,7 +1650,7 @@ static void hugetlb_unregister_all_nodes
>>   * Register hstate attributes for a single node sysdev.
>>   * No-op if attributes already registered.
>>   */
>> -void hugetlb_register_node(struct node *node)
>> +void __init hugetlb_register_node(struct node *node)
>>  {
>>  	struct hstate *h;
>>  	struct node_hstate *nhs = &node_hstates[node->sysdev.id];


- -- 
Jeff Mahoney
SUSE Labs
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.12 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org/

iEYEARECAAYFAktN2NsACgkQLPWxlyuTD7LWzACcDpwbTkDEaZpdHUOYBiFqj0xP
9NkAnjoySOmUkV45P8yaMK6Z7N8xWnvn
=dTst
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
