Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 799A06B02EF
	for <linux-mm@kvack.org>; Tue,  2 Jan 2018 22:11:22 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id d9so72948qkg.13
        for <linux-mm@kvack.org>; Tue, 02 Jan 2018 19:11:22 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d75si84906qkj.149.2018.01.02.19.11.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jan 2018 19:11:21 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id w033AVid065378
	for <linux-mm@kvack.org>; Tue, 2 Jan 2018 22:11:20 -0500
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2f8pjggtwp-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 02 Jan 2018 22:11:20 -0500
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 3 Jan 2018 03:11:17 -0000
Subject: Re: [RFC PATCH 1/3] mm, numa: rework do_pages_move
References: <20171207143401.GK20234@dhcp22.suse.cz>
 <20171208161559.27313-1-mhocko@kernel.org>
 <20171208161559.27313-2-mhocko@kernel.org>
 <2e467ad3-a443-bde4-afa2-664bca57914f@linux.vnet.ibm.com>
 <20180102121237.GC25397@dhcp22.suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 3 Jan 2018 08:41:09 +0530
MIME-Version: 1.0
In-Reply-To: <20180102121237.GC25397@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <1380d06b-e15b-8fdd-8e31-a6457db634a4@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andrea Reale <ar@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On 01/02/2018 05:42 PM, Michal Hocko wrote:
> On Tue 02-01-18 16:55:46, Anshuman Khandual wrote:
>> On 12/08/2017 09:45 PM, Michal Hocko wrote:
>>> From: Michal Hocko <mhocko@suse.com>
>>>
>>> do_pages_move is supposed to move user defined memory (an array of
>>> addresses) to the user defined numa nodes (an array of nodes one for
>>> each address). The user provided status array then contains resulting
>>> numa node for each address or an error. The semantic of this function is
>>> little bit confusing because only some errors are reported back. Notably
>>> migrate_pages error is only reported via the return value. This patch
>>
>> It does report back the migration failures as well. In new_page_node
>> there is '*result = &pm->status' which going forward in unmap_and_move
>> will hold migration error or node ID of the new page.
>>
>> 	newpage = get_new_page(page, private, &result);
>> 	............
>> 	if (result) {
>> 		if (rc)
>> 			*result = rc;
>> 		else
>> 			*result = page_to_nid(newpage);
>> 	}
>>
> 
> This is true, except the user will not get this information. Have a look
> how we do not copy status on error up in the do_pages_move layer.

Ahh, right, we dont. But as you have mentioned this patch does not
intend to change the semantics of status return thought it seems
like the right thing to do. We can just pass on the status to user
here before bailing out.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
