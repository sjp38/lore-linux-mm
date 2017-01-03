Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A24DB6B0069
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 04:17:45 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id m203so78355568wma.2
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 01:17:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d7si76456273wjf.81.2017.01.03.01.17.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Jan 2017 01:17:44 -0800 (PST)
Date: Tue, 3 Jan 2017 10:17:42 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] nodemask: Consider MAX_NUMNODES inside node_isset
Message-ID: <20170103091741.GD30111@dhcp22.suse.cz>
References: <20170103082753.25758-1-khandual@linux.vnet.ibm.com>
 <20170103084418.GC30111@dhcp22.suse.cz>
 <6c7ecb18-2ad0-f38a-1dc8-3c6c405b87ce@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6c7ecb18-2ad0-f38a-1dc8-3c6c405b87ce@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, vbabka@suse.cz, akpm@linux-foundation.org

On Tue 03-01-17 14:37:09, Anshuman Khandual wrote:
> On 01/03/2017 02:14 PM, Michal Hocko wrote:
> > On Tue 03-01-17 13:57:53, Anshuman Khandual wrote:
> >> node_isset can give incorrect result if the node number is beyond the
> >> bitmask size (MAX_NUMNODES in this case) which is not checked inside
> >> test_bit. Hence check for the bit limits (MAX_NUMNODES) inside the
> >> node_isset function before calling test_bit.
> > Could you be more specific when such a thing might happen? Have you seen
> > any in-kernel user who would give such a bogus node?
> 
> Have not seen this through any in-kernel use case. While rebasing the CDM
> zonelist rebuilding series,

Then fix this particular code path...

> I came across this through an error path when
> a bogus node value of 256 (MAX_NUMNODES on POWER) is received when we call
> first_node() on an empty nodemask (which itself seems weird as well).

Does calling first_node on an empty nodemask make any sense? If there is
a risk then I would expect nodes_empty() check before doing any mask
related operations.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
