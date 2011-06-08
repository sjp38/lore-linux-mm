Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B28726B004A
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 20:15:18 -0400 (EDT)
Message-ID: <4DEEBF0F.1070902@fnarfbargle.com>
Date: Wed, 08 Jun 2011 08:15:11 +0800
From: Brad Campbell <brad@fnarfbargle.com>
MIME-Version: 1.0
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
References: <20110601011527.GN19505@random.random> <alpine.LSU.2.00.1105312120530.22808@sister.anvils> <4DE5DCA8.7070704@fnarfbargle.com> <4DE5E29E.7080009@redhat.com> <4DE60669.9050606@fnarfbargle.com> <4DE60918.3010008@redhat.com> <4DE60940.1070107@redhat.com> <4DE61A2B.7000008@fnarfbargle.com> <20110601111841.GB3956@zip.com.au> <4DE62801.9080804@fnarfbargle.com> <20110601230342.GC3956@zip.com.au> <4DE8E3ED.7080004@fnarfbargle.com> <isavsg$3or$1@dough.gmane.org> <4DE906C0.6060901@fnarfbargle.com> <4DED344D.7000005@pandora.be> <4DED9C23.2030408@fnarfbargle.com> <4DEE27DE.7060004@trash.net> <4DEE3859.6070808@fnarfbargle.com> <4DEE6815.7040504@pandora.be>
In-Reply-To: <4DEE6815.7040504@pandora.be>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart De Schuymer <bdschuym@pandora.be>
Cc: Patrick McHardy <kaber@trash.net>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org

On 08/06/11 02:04, Bart De Schuymer wrote:

> If the bug is easily triggered with your guest os, then you could try to
> capture the traffic with wireshark (or something else) in a
> configuration that doesn't crash your system. Save the traffic in a pcap
> file. Then you can see if resending that traffic in the vulnerable
> configuration triggers the bug (I don't know if something in Windows
> exists, but tcpreplay should work for Linux). Once you have such a
> capture , chances are the bug is even easily reproducible by us (unless
> it's hardware-specific). Success isn't guaranteed, but I think it's
> worth a shot...

The issue with this is I don't have a configuration that does not crash 
the system. This only happens under the specific circumstance that 
traffic from VM A is being DNAT'd to VM B. If I disable 
CONFIG_BRIDGE_NETFILTER, or I leave out the DNAT then I can't replicate 
the problem as I don't seem to be able to get the packets to go where I 
want them to go.

Let me try and explain it a little more clearly with made up IP 
addresses to illustrate the problem.

I have VM A (1.1.1.2) and VM B (1.1.1.3) on br1 (1.1.1.1)
I have public IP on ppp0 (2.2.2.2).

VM B can talk to VM A using its host address (1.1.1.2) and there is no 
problem.

The DNAT says anything destined for PPP0 that is on port 443 and coming 
from anywhere other than PPP0 (ie inside the network) is to be DNAT'd to 
1.1.1.3.

So VM B (1.1.1.3) tries to connect to ppp0 (2.2.2.2) on port 443, and 
this is redirected to VM B on 1.1.1.2.

Only under this specific circumstance does the problem occur. I can get 
VM B (1.1.1.3) to talk directly to VM A (1.1.1.2) all day long and there 
is no problem, it's only when VM B tries to talk to ppp0 that there is 
an issue (and it happens within seconds of the initial connection).

All these tests have been performed with VM B being a Windows XP guest. 
Tonight I'll try it with a Linux guest and see if I can make it happen. 
If that works I might be able to come up with some reproducible test 
case for you. I have a desktop machine that has Intel VT extensions, so 
I'll work toward making a portable test case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
