Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 01F656B005A
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 14:39:43 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id va7so2422029obc.14
        for <linux-mm@kvack.org>; Fri, 05 Oct 2012 11:39:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <506E313B.5010303@jp.fujitsu.com>
References: <1348724705-23779-1-git-send-email-wency@cn.fujitsu.com>
 <1348724705-23779-3-git-send-email-wency@cn.fujitsu.com> <CAHGf_=rLMsmAxR5hrDVXjkHAxmupVrmtqE3iq2qu=O9Prp4nSg@mail.gmail.com>
 <5064EA5A.3080905@jp.fujitsu.com> <CAHGf_=qbBGjTL9oBHz7AM8BAosbzvn_WAGdAzJ8np-nDPN_KFQ@mail.gmail.com>
 <5064FDCA.1020504@jp.fujitsu.com> <CAHGf_=r+oz0GS137e81EySbN-3KVmQisF8sySiCUYUas1RZLtQ@mail.gmail.com>
 <5065740A.2000502@jp.fujitsu.com> <CAHGf_=o_FLsEULK3s1+zD-A0FL5QvKnX542Lz4vCwVVV2fYNRw@mail.gmail.com>
 <50693E30.3010006@jp.fujitsu.com> <CAHGf_=qZVe_KfThZa5yEm+4w3MMREs1xqya5HmKWsWjyTcjkzA@mail.gmail.com>
 <506E313B.5010303@jp.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 5 Oct 2012 14:39:22 -0400
Message-ID: <CAHGf_=qn4m6x95h5uV6jXibc0RmTH-1ZC17vSUTyTTXktfd23g@mail.gmail.com>
Subject: Re: [PATCH 2/4] memory-hotplug: add node_device_release
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: wency@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org

> I have the reason to have to fill the node struct with 0 by memset.
> The node is a part of node struct array (node_devices[]).
> If we add empty release function for suppressing warning,
> some data remains in the node struct after hot removing memory.
> So if we re-hot adds the memory, the node struct is reused by
> register_onde_node(). But the node struct has some data, because
> it was not initialized with 0. As a result, more waning is shown
> by the remained data at hot addinig memory as follows:

Even though you call memset(0) at offline. It doesn't guarantee the memory
keep 0 until online. E.g. physical memory exchange during offline, bit
corruption
by cosmic ray, etc. So, you should fill zero at online phase explicitly if need.

The basic hotplug design is: you should forget everything at offline
and you shouldn't
assume any initialized data at online.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
