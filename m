Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id D687A6B0263
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 13:10:04 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id fl2so1967920pad.7
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 10:10:04 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 88si16353490pfs.216.2016.10.24.10.10.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 10:10:04 -0700 (PDT)
Subject: Re: [RFC 2/8] mm: Add specialized fallback zonelist for coherent
 device memory nodes
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1477283517-2504-3-git-send-email-khandual@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <580E406B.4050205@intel.com>
Date: Mon, 24 Oct 2016 10:10:03 -0700
MIME-Version: 1.0
In-Reply-To: <1477283517-2504-3-git-send-email-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com

On 10/23/2016 09:31 PM, Anshuman Khandual wrote:
> +#ifdef CONFIG_COHERENT_DEVICE
> +		/*
> +		 * Isolation requiring coherent device memory node's zones
> +		 * should not be part of any other node's fallback zonelist
> +		 * but it's own fallback list.
> +		 */
> +		if (isolated_cdm_node(node) && (pgdat->node_id != node))
> +			continue;
> +#endif

Total nit:  Why do you need an #ifdef here when you had

+#ifdef CONFIG_COHERENT_DEVICE
+#define node_cdm(nid)          (NODE_DATA(nid)->coherent_device)
+#define set_cdm_isolation(nid) (node_cdm(nid) = 1)
+#define clr_cdm_isolation(nid) (node_cdm(nid) = 0)
+#define isolated_cdm_node(nid) (node_cdm(nid) == 1)
+#else
+#define set_cdm_isolation(nid) ()
+#define clr_cdm_isolation(nid) ()
+#define isolated_cdm_node(nid) (0)
+#endif

in your last patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
