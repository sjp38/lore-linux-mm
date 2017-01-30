Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 498AC6B0038
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 12:54:29 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 201so462221107pfw.5
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 09:54:29 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r23si9002593pgo.422.2017.01.30.09.54.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jan 2017 09:54:28 -0800 (PST)
Subject: Re: [RFC V2 12/12] mm: Tag VMA with VM_CDM flag explicitly during
 mbind(MPOL_BIND)
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
 <20170130033602.12275-13-khandual@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <26a17cd1-dd50-43b9-03b1-dd967466a273@intel.com>
Date: Mon, 30 Jan 2017 09:54:27 -0800
MIME-Version: 1.0
In-Reply-To: <20170130033602.12275-13-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dan.j.williams@intel.com

On 01/29/2017 07:35 PM, Anshuman Khandual wrote:
> +		if ((new_pol->mode == MPOL_BIND)
> +			&& nodemask_has_cdm(new_pol->v.nodes))
> +			set_vm_cdm(vma);

So, if you did:

	mbind(addr, PAGE_SIZE, MPOL_BIND, all_nodes, ...);
	mbind(addr, PAGE_SIZE, MPOL_BIND, one_non_cdm_node, ...);

You end up with a VMA that can never have KSM done on it, etc...  Even
though there's no good reason for it.  I guess /proc/$pid/smaps might be
able to help us figure out what was going on here, but that still seems
like an awful lot of damage.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
