Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D2B686B0038
	for <linux-mm@kvack.org>; Sun, 25 Dec 2016 04:11:24 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id l2so20801649wml.5
        for <linux-mm@kvack.org>; Sun, 25 Dec 2016 01:11:24 -0800 (PST)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.19])
        by mx.google.com with ESMTPS id uz2si42220545wjb.9.2016.12.25.01.11.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Dec 2016 01:11:23 -0800 (PST)
From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: Re: [PATCH v6 4/4] of/fdt: mark hotpluggable memory
Date: Sun, 25 Dec 2016 10:02:22 +0100
Message-Id: <20161225090222.3703-1-xypron.glpk@gmx.de>
In-Reply-To: <1478562276-25539-5-git-send-email-arbab@linux.vnet.ibm.com>
References: <1478562276-25539-5-git-send-email-arbab@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Balbir Singh <bsingharora@gmail.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, "H . Peter Anvin" <hpa@zytor.com>, Alistair Popple <apopple@au1.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Frank Rowand <frowand.list@gmail.com>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Paul Mackerras <paulus@samba.org>, Rob Herring <robh+dt@kernel.org>, Stewart Smith <stewart@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, devicetree@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Heinrich Schuchardt <xypron.glpk@gmx.de>

The patch adds a new property "linux,hotpluggable" to memory nodes of the
device tree.

memory@0 {
	reg = <0x0 0x01000000 0x0 0x7f000000>;
	linux,hotpluggable;
}

Memory areas marked by this property can later be disabled using the hotplugging
API. Especially for virtual machines this is a very useful capability.

Unfortunately the notation chosen does not fit well with the concept of
devicetree overlays which allow to change the devicetree during runtime.

I suggest to use the following notation

memory@0 {
	compatible = "linux,hotpluggable-memory";
	reg = <0x0 0x01000000 0x0 0x7f000000>;
	status = "disabled";
}

This will allow us to write a device driver that can react to changes of the
devicetree made via devicetree overlays.

This driver could react to the change of the status between "okay" and
"disabled" and update the memory status accordingly.

Further we could use devicetree overlays to provide additional hotpluggable
memory.

The referenced patch has already been pulled for 4.10. But I hope it is not
too late for this design change.

Best regards

Heinrich Schuchardt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
