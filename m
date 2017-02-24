From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v4 14/28] Add support to access boot related data in
 the clear
Date: Fri, 24 Feb 2017 11:21:55 +0100
Message-ID: <20170224102155.4pauis3acrzp3rwz@pd.tnic>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154508.19244.58580.stgit@tlendack-t1.amdoffice.net>
 <20170221150625.lohyskz5bjuey7fa@pd.tnic>
 <031277bf-25ad-3d41-d189-1ad6b4d27c93@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <031277bf-25ad-3d41-d189-1ad6b4d27c93@amd.com>
Sender: kvm-owner@vger.kernel.org
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>
List-Id: linux-mm.kvack.org

On Thu, Feb 23, 2017 at 03:34:30PM -0600, Tom Lendacky wrote:
> Hmm... maybe I'm missing something here.  This doesn't have anything to
> do with kexec or efi_reuse_config.  This has to do with the fact that

I said kexec because kexec uses the setup_data mechanism to pass config
tables to the second kernel, for example.

> when a system boots the setup data and the EFI data are not encrypted.
> Since it's not encrypted we need to be sure that any early_memremap()
> and memremap() calls remove the encryption mask from the resulting
> pagetable entry that is created so the data can be accessed properly.

Anyway, I'd prefer not to do this ad-hoc caching if it can be
helped. You're imposing an arbitrary limit of 32 there which the
setup_data linked list doesn't have. So if you really want to go
inspect those elements, you could iterate over them starting from
boot_params.hdr.setup_data, just like parse_setup_data() does. Most of
the time that list should be non-existent and if it is, it will be short
anyway.

And if we really decide that we need to cache it for later inspection
due to speed considerations, as you do in memremap_is_setup_data(), you
could do that in the default: branch of parse_setup_data() and do it
just once: I don't see why you need to do add_to_setup_data_list() *and*
update_setup_data_list() when you could add both pointer and updated
size once.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
