Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 25A0A6B2C79
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 13:01:57 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id e89so3509995pfb.17
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 10:01:57 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id r18si16436726pls.115.2018.11.22.10.01.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 10:01:55 -0800 (PST)
Subject: Re: [PATCH 0/7] ACPI HMAT memory sysfs representation
References: <20181114224902.12082-1-keith.busch@intel.com>
 <1ed406b2-b85f-8e02-1df0-7c39aa21eca9@arm.com>
 <4ea6e80f-80ba-6992-8aa0-5c2d88996af7@intel.com>
 <b79804b0-32ee-03f9-fa62-a89684d46be6@arm.com>
 <c6abb754-0d82-8739-fe08-24e9402bae75@intel.com>
 <aae34dde-fa70-870a-9b74-fff9e385bfc9@arm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <f5315662-5c1a-68a3-4d04-21b4b5ca94b1@intel.com>
Date: Thu, 22 Nov 2018 10:01:53 -0800
MIME-Version: 1.0
In-Reply-To: <aae34dde-fa70-870a-9b74-fff9e385bfc9@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>, Keith Busch <keith.busch@intel.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dan Williams <dan.j.williams@intel.com>

On 11/22/18 3:52 AM, Anshuman Khandual wrote:
>>
>> It sounds like the subset that's being exposed is insufficient for yo
>> We did that because we think doing anything but a subset in sysfs will
>> just blow up sysfs:  MAX_NUMNODES is as high as 1024, so if we have 4
>> attributes, that's at _least_ 1024*1024*4 files if we expose *all*
>> combinations.
> Each permutation need not be a separate file inside all possible NODE X
> (/sys/devices/system/node/nodeX) directories. It can be a top level file
> enumerating various attribute values for a given (X, Y) node pair based
> on an offset something like /proc/pid/pagemap.

My assumption has been that this kind of thing is too fancy for sysfs:

Documentation/filesystems/sysfs.txt:
> Attributes should be ASCII text files, preferably with only one value
> per file. It is noted that it may not be efficient to contain only one
> value per file, so it is socially acceptable to express an array of
> values of the same type. 
> 
> Mixing types, expressing multiple lines of data, and doing fancy
> formatting of data is heavily frowned upon. Doing these things may get
> you publicly humiliated and your code rewritten without notice. 

/proc/pid/pagemap is binary, not one-value-per-file and relatively
complicated to parse.

Do you really think following something like pagemap is the right model
for sysfs?

BTW, I'm not saying we don't need *some* interface like you propose.  We
almost certainly will at some point.  I just don't think it will be in
sysfs.
