Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 18EAE6B0038
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 23:54:53 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id bj1so1497475pad.15
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 20:54:52 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id br4si2629964pbc.155.2014.10.01.20.54.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 01 Oct 2014 20:54:51 -0700 (PDT)
Message-ID: <542CCBCB.9000709@oracle.com>
Date: Wed, 01 Oct 2014 23:51:39 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] mm: poison critical mm/ structs
References: <1412041639-23617-1-git-send-email-sasha.levin@oracle.com>	<20141001140725.fd7f1d0cf933fbc2aa9fc1b1@linux-foundation.org>	<542C749B.1040103@oracle.com> <20141001144834.ff3ff0349951df734d159fb3@linux-foundation.org>
In-Reply-To: <20141001144834.ff3ff0349951df734d159fb3@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, mgorman@suse.de

On 10/01/2014 05:48 PM, Andrew Morton wrote:
> On Wed, 01 Oct 2014 17:39:39 -0400 Sasha Levin <sasha.levin@oracle.com> wrote:
> 
>>> It looks fairly cheap - I wonder if it should simply fall under
>>> CONFIG_DEBUG_VM rather than the new CONFIG_DEBUG_VM_POISON.
>>
>> Config options are cheap as well :)
> 
> Thing is, lots of people are enabling CONFIG_DEBUG_VM, but a smaller
> number of people will enable CONFIG_DEBUG_VM_POISON.  Less coverage. 
> 
> Defaulting to y if CONFIG_DEBUG_VM might help, but if people do `make
> oldconfig' when CONFIG_DEBUG_VM=n, their CONFIG_DEBUG_VM_POISON will
> get set to `n' and will remain that way when they set CONFIG_DEBUG_VM
> again.

In that case, what about:

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index db41b15..b2c7038 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -546,6 +546,7 @@ config DEBUG_VM_RB
 config DEBUG_VM_POISON
        bool "Poison VM structures"
        depends on DEBUG_VM
+       def_bool y
        help
          Add poison to the beggining and end of various VM structure to
          detect memory corruption in VM management code.

We'll default to "Y" in 'make oldconfig' and it'll automatically be switched
on when the user selects CONFIG_DEBUG_VM=y, but we still keep the advantages
of having it in a different config option.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
