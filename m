Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id D11AE6B0038
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 18:08:48 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id 101so5464023iom.7
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 15:08:48 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d76si3056531ith.121.2017.02.08.15.08.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 15:08:48 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v18N4GYv060650
	for <linux-mm@kvack.org>; Wed, 8 Feb 2017 18:08:47 -0500
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28g0tc68em-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 Feb 2017 18:08:47 -0500
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gwshan@linux.vnet.ibm.com>;
	Thu, 9 Feb 2017 09:08:44 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 9286E3578052
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 10:08:41 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v18N8XkA34734166
	for <linux-mm@kvack.org>; Thu, 9 Feb 2017 10:08:41 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v18N89Vl006667
	for <linux-mm@kvack.org>; Thu, 9 Feb 2017 10:08:09 +1100
Date: Thu, 9 Feb 2017 10:07:44 +1100
From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/page_alloc: Fix nodes for reclaim in fast path
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
References: <1486532455-29613-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <20170208100850.GD5686@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170208100850.GD5686@dhcp22.suse.cz>
Message-Id: <20170208230744.GB4142@gwshan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>, linux-mm@kvack.org, mgorman@suse.de, akpm@linux-foundation.org, anton@samba.org, mpe@ellerman.id.au, "# v3 . 16+" <stable@vger.kernel.org>

On Wed, Feb 08, 2017 at 11:08:50AM +0100, Michal Hocko wrote:
>On Wed 08-02-17 16:40:55, Gavin Shan wrote:
>> When @node_reclaim_node isn't 0, the page allocator tries to reclaim
>> pages if the amount of free memory in the zones are below the low
>> watermark. On Power platform, none of NUMA nodes are scanned for page
>> reclaim because no nodes match the condition in zone_allows_reclaim().
>> On Power platform, RECLAIM_DISTANCE is set to 10 which is the distance
>> of Node-A to Node-A. So the preferred node even won't be scanned for
>> page reclaim.
>
>This is quite confusing. I can see 56608209d34b ("powerpc/numa: Set a
>smaller value for RECLAIM_DISTANCE to enable zone reclaim") which
>enforced the zone_reclaim by reducing the RECLAIM_DISTANCE, now you are
>building on top of that. Having RECLAIM_DISTANCE == LOCAL_DISTANCE is
>really confusing. What are distances of other nodes (in other words what
>does numactl --hardware tells)?

oops, missed to paste the output from numactl:

# numactl --hardware
available: 2 nodes (0,8)
node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79
node 0 size: 130703 MB
node 0 free: 127424 MB
node 8 cpus: 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159
node 8 size: 130647 MB
node 8 free: 130038 MB
node distances:
node   0   8 
  0:  10  40 
  8:  40  10 

Thanks,
Gavin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
