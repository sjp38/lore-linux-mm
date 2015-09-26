Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id 6C0576B0038
	for <linux-mm@kvack.org>; Sat, 26 Sep 2015 13:56:27 -0400 (EDT)
Received: by ykft14 with SMTP id t14so141887773ykf.0
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 10:56:27 -0700 (PDT)
Received: from mail-yk0-x230.google.com (mail-yk0-x230.google.com. [2607:f8b0:4002:c07::230])
        by mx.google.com with ESMTPS id w64si4443940ywb.54.2015.09.26.10.56.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Sep 2015 10:56:26 -0700 (PDT)
Received: by ykdg206 with SMTP id g206so139961800ykd.1
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 10:56:26 -0700 (PDT)
Date: Sat, 26 Sep 2015 13:56:22 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 5/7] x86, acpi, cpu-hotplug: Introduce
 apicid_to_cpuid[] array to store persistent cpuid <-> apicid mapping.
Message-ID: <20150926175622.GC3572@htj.duckdns.org>
References: <1441859269-25831-1-git-send-email-tangchen@cn.fujitsu.com>
 <1441859269-25831-6-git-send-email-tangchen@cn.fujitsu.com>
 <20150910195532.GK8114@mtj.duckdns.org>
 <56066AC9.6020703@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56066AC9.6020703@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: jiang.liu@linux.intel.com, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, qiaonuohan@cn.fujitsu.com, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, Sep 26, 2015 at 05:52:09PM +0800, Tang Chen wrote:
> >>+static int allocate_logical_cpuid(int apicid)
> >>+{
> >>+	int i;
> >>+
> >>+	/*
> >>+	 * cpuid <-> apicid mapping is persistent, so when a cpu is up,
> >>+	 * check if the kernel has allocated a cpuid for it.
> >>+	 */
> >>+	for (i = 0; i < max_logical_cpuid; i++) {
> >>+		if (cpuid_to_apicid[i] == apicid)
> >>+			return i;
> >>+	}
> >>+
> >>+	/* Allocate a new cpuid. */
> >>+	if (max_logical_cpuid >= nr_cpu_ids) {
> >>+		WARN_ONCE(1, "Only %d processors supported."
> >>+			     "Processor %d/0x%x and the rest are ignored.\n",
> >>+			     nr_cpu_ids - 1, max_logical_cpuid, apicid);
> >>+		return -1;
> >>+	}
> >So, the original code didn't have this failure mode, why is this
> >different for the new code?
> 
> It is not different. Since max_logical_cpuid is new, this is ensure it won't
> go beyond NR_CPUS.

If the above condition can happen, the original code should have had a
similar check as above, right?  Sure, max_logical_cpuid is a new thing
but that doesn't seem to change whether the above condition can happen
or not, no?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
