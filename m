Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B548E6B0069
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 20:09:13 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id e9so148037615pgc.5
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 17:09:13 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id f35si4785300plh.192.2016.12.15.17.09.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Dec 2016 17:09:12 -0800 (PST)
Subject: Re: [Qemu-devel] [PATCH kernel v5 0/5] Extend virtio-balloon for fast
 (de)inflating & fast live migration
References: <1480495397-23225-1-git-send-email-liang.z.li@intel.com>
 <f67ca79c-ad34-59dd-835f-e7bc9dcaef58@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E3A130C01@shsmsx102.ccr.corp.intel.com>
 <0b18c636-ee67-cbb4-1ba3-81a06150db76@redhat.com>
 <0b83db29-ebad-2a70-8d61-756d33e33a48@intel.com>
 <2171e091-46ee-decd-7348-772555d3a5e3@redhat.com>
 <d3ff453c-56fa-19de-317c-1c82456f2831@intel.com>
 <20161207183817.GE28786@redhat.com>
 <b58fd9f6-d9dd-dd56-d476-dd342174dac5@intel.com>
 <20161207202824.GH28786@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E3A14E2AD@SHSMSX104.ccr.corp.intel.com>
 <060287c7-d1af-45d5-70ea-ad35d4bbeb84@intel.com>
 <F2CBF3009FA73547804AE4C663CAB28E3C31D0E6@SHSMSX104.ccr.corp.intel.com>
 <01886693-c73e-3696-860b-086417d695e1@intel.com>
 <F2CBF3009FA73547804AE4C663CAB28E3C32985A@shsmsx102.ccr.corp.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <f517bfbe-18b8-6962-5c57-545f6ef47ad0@intel.com>
Date: Thu, 15 Dec 2016 17:09:10 -0800
MIME-Version: 1.0
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E3C32985A@shsmsx102.ccr.corp.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: David Hildenbrand <david@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "mhocko@suse.com" <mhocko@suse.com>, "mst@redhat.com" <mst@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>

On 12/15/2016 04:48 PM, Li, Liang Z wrote:
>>> It seems we leave too many bit  for the pfn, and the bits leave for
>>> length is not enough, How about keep 45 bits for the pfn and 19 bits
>>> for length, 45 bits for pfn can cover 57 bits physical address, that should be
>> enough in the near feature.
>>> What's your opinion?
>> I still think 'order' makes a lot of sense.  But, as you say, 57 bits is enough for
>> x86 for a while.  Other architectures.... who knows?

Thinking about this some more...  There are really only two cases that
matter: 4k pages and "much bigger" ones.

Squeezing each 4k page into 8 bytes of metadata helps guarantee that
this scheme won't regress over the old scheme in any cases.  For bigger
ranges, 8 vs 16 bytes means *nothing*.  And 16 bytes will be as good or
better than the old scheme for everything which is >4k.

How about this:
 * 52 bits of 'pfn', 5 bits of 'order', 7 bits of 'length'
 * One special 'length' value to mean "actual length in next 8 bytes"

That should be pretty simple to produce and decode.  We have two record
sizes, but I think it is manageable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
