Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 55AA16B0033
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 13:26:35 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id o60so8580813wrc.14
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 10:26:35 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 90sor5066626wrp.84.2017.11.21.10.26.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 Nov 2017 10:26:33 -0800 (PST)
From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Subject: [RFC v4 01/10] S.A.R.A. Documentation
Date: Tue, 21 Nov 2017 19:26:03 +0100
Message-Id: <1511288772-19308-2-git-send-email-s.mesoraca16@gmail.com>
In-Reply-To: <1511288772-19308-1-git-send-email-s.mesoraca16@gmail.com>
References: <1511288772-19308-1-git-send-email-s.mesoraca16@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-security-module@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, Salvatore Mesoraca <s.mesoraca16@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Brad Spengler <spender@grsecurity.net>, Casey Schaufler <casey@schaufler-ca.com>, Christoph Hellwig <hch@infradead.org>, James Morris <james.l.morris@oracle.com>, Jann Horn <jannh@google.com>, Kees Cook <keescook@chromium.org>, PaX Team <pageexec@freemail.hu>, Thomas Gleixner <tglx@linutronix.de>, "Serge E. Hallyn" <serge@hallyn.com>

Adding documentation for S.A.R.A. LSM.

Signed-off-by: Salvatore Mesoraca <s.mesoraca16@gmail.com>
---
 Documentation/admin-guide/LSM/SARA.rst          | 173 ++++++++++++++++++++++++
 Documentation/admin-guide/LSM/index.rst         |   1 +
 Documentation/admin-guide/kernel-parameters.txt |  24 ++++
 3 files changed, 198 insertions(+)
 create mode 100644 Documentation/admin-guide/LSM/SARA.rst

diff --git a/Documentation/admin-guide/LSM/SARA.rst b/Documentation/admin-guide/LSM/SARA.rst
new file mode 100644
index 0000000..de41b78
--- /dev/null
+++ b/Documentation/admin-guide/LSM/SARA.rst
@@ -0,0 +1,173 @@
+========
+S.A.R.A.
+========
+
+S.A.R.A. (S.A.R.A. is Another Recursive Acronym) is a stacked Linux Security
+Module that aims to collect heterogeneous security measures, providing a common
+interface to manage them.
+As of today it consists of one submodule:
+
+- WX Protection
+
+
+The kernel-space part is complemented by its user-space counterpart: `saractl`
+[2]_.
+A test suite for WX Protection, called `sara-test` [4]_, is also available.
+More information about where to find these tools and the full S.A.R.A.
+documentation are in the `External Links and Documentation`_ section.
+
+-------------------------------------------------------------------------------
+
+S.A.R.A.'s Submodules
+=====================
+
+WX Protection
+-------------
+WX Protection aims to improve user-space programs security by applying:
+
+- `W^X enforcement`_
+- `W!->X (once writable never executable) mprotect restriction`_
+- `Executable MMAP prevention`_
+
+All of the above features can be enabled or disabled both system wide
+or on a per executable basis through the use of configuration files managed by
+`saractl` [2]_.
+
+It is important to note that some programs may have issues working with
+WX Protection. In particular:
+
+- **W^X enforcement** will cause problems to any programs that needs
+  memory pages mapped both as writable and executable at the same time e.g.
+  programs with executable stack markings in the *PT_GNU_STACK* segment.
+- **W!->X mprotect restriction** will cause problems to any program that
+  needs to generate executable code at run time or to modify executable
+  pages e.g. programs with a *JIT* compiler built-in or linked against a
+  *non-PIC* library.
+- **Executable MMAP prevention** can work only with programs that have at least
+  partial *RELRO* support. It's disabled automatically for programs that
+  lack this feature. It will cause problems to any program that uses *dlopen*
+  or tries to do an executable mmap. Unfortunately this feature is the one
+  that could create most problems and should be enabled only after careful
+  evaluation.
+
+To extend the scope of the above features, despite the issues that they may
+cause, they are complemented by **/proc/PID/attr/sara/wxprot** interface
+and **trampoline emulation**.
+
+At the moment, WX Protection (unless specified otherwise) should work on
+any architecture supporting the NX bit, including, but not limited to:
+`x86_64`, `x86_32` (with PAE), `ARM` and `ARM64`.
+
+Parts of WX Protection are inspired by some of the features available in PaX.
+
+For further information about configuration file format and user-space
+utilities please take a look at the full documentation [1]_.
+
+W^X enforcement
+^^^^^^^^^^^^^^^
+W^X means that a program can't have a page of memory that is marked, at the
+same time, writable and executable. This also allow to detect many bad
+behaviours that make life much more easy for attackers. Programs running with
+this feature enabled will be more difficult to exploit in the case they are
+affected by some vulnerabilities, because the attacker will be forced
+to make more steps in order to exploit them.
+
+W!->X (once writable never executable) mprotect restriction
+^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
+"Once writable never executable" means that any page that could have been
+marked as writable in the past won't ever be allowed to be marked (e.g. via
+an mprotect syscall) as executable.
+This goes on the same track as W^X, but is much stricter and prevents
+the runtime creation of new executable code in memory.
+Obviously, this feature does not prevent a program from creating a new file and
+*mmapping* it as executable, however, it will be way more difficult for
+attackers to exploit vulnerabilities if this feature is enabled.
+
+Executable MMAP prevention
+^^^^^^^^^^^^^^^^^^^^^^^^^^
+This feature prevents the creation of new executable mmaps after the dynamic
+libraries have been loaded. When used in combination with **W!->X mprotect
+restriction** this feature will completely prevent the creation of new
+executable code from the current thread.
+Obviously, this feature does not prevent cases in which an attacker uses an
+*execve* to start a completely new program. This kind of restriction, if
+needed, can be applied using one of the other LSM that focuses on MAC.
+Please be aware that this feature can break many programs and so it should be
+enabled after careful evaluation.
+
+/proc/PID/attr/sara/wxprot interface
+^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
+The `procattr` interface can be used by a thread to discover which
+WX Protection features are enabled and/or to tighten them: protection
+can't be softened via procattr.
+The interface is simple: it's a text file with an hexadecimal
+number in it representing enabled features (more information can be
+found in the `Flags values`_ section). Via this interface it is also
+possible to perform a complete memory scan to remove the write permission
+from pages that are both writable and executable, please note that this
+change will also affect other threads of the same process.
+
+Protections that prevent the runtime creation of executable code
+can be troublesome for all those programs that actually need to do it
+e.g. programs shipping with a JIT compiler built-in.
+This feature can be use to run the JIT compiler with few restrictions
+while enforcing full WX Protection in the rest of the program.
+
+The preferred way to access this interface is via `libsara` [3]_.
+If you don't want it as a dependency, you can just statically link it
+in your project or copy/paste parts of it.
+To make things simpler `libsara` is the only part of S.A.R.A. released under
+*CC0 - No Rights Reserved* license.
+
+Trampoline emulation
+^^^^^^^^^^^^^^^^^^^^
+Some programs need to generate part of their code at runtime. Luckily enough,
+in some cases they only generate well-known code sequences (the
+*trampolines*) that can be easily recognized and emulated by the kernel.
+This way WX Protection can still be active, so a potential attacker won't be
+able to generate arbitrary sequences of code, but just those that are
+explicitly allowed. This is not ideal, but it's still better than having WX
+Protection completely disabled.
+
+In particular S.A.R.A. is able to recognize trampolines used by GCC for nested
+C functions and libffi's trampolines.
+This feature is available only on `x86_32` and `x86_64`.
+
+Flags values
+^^^^^^^^^^^^
+Flags are represented as a 16 bit unsigned integer in which every bit indicates
+the status of a given feature:
+
++------------------------------+----------+
+|           Feature            |  Value   |
++==============================+==========+
+| W!->X Heap                   |  0x0001  |
++------------------------------+----------+
+| W!->X Stack                  |  0x0002  |
++------------------------------+----------+
+| W!->X Other memory           |  0x0004  |
++------------------------------+----------+
+| W^X                          |  0x0008  |
++------------------------------+----------+
+| Don't enforce, just complain |  0x0010  |
++------------------------------+----------+
+| Be Verbose                   |  0x0020  |
++------------------------------+----------+
+| Executable MMAP prevention   |  0x0040  |
++------------------------------+----------+
+| Force W^X on setprocattr     |  0x0080  |
++------------------------------+----------+
+| Trampoline emulation         |  0x0100  |
++------------------------------+----------+
+| Children will inherit flags  |  0x0200  |
++------------------------------+----------+
+
+-------------------------------------------------------------------------------
+
+External Links and Documentation
+================================
+
+.. [1] `Documentation	<https://sara.smeso.it>`_
+.. [2] `saractl		<https://github.com/smeso/saractl>`_
+.. [3] `libsara		<https://github.com/smeso/libsara>`_
+.. [4] `sara-test	<https://github.com/smeso/sara-test>`_
diff --git a/Documentation/admin-guide/LSM/index.rst b/Documentation/admin-guide/LSM/index.rst
index c980dfe..c0ae6bb3 100644
--- a/Documentation/admin-guide/LSM/index.rst
+++ b/Documentation/admin-guide/LSM/index.rst
@@ -39,3 +39,4 @@ the one "major" module (e.g. SELinux) if there is one configured.
    Smack
    tomoyo
    Yama
+   SARA
diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index 62436bd..20c9114 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -3817,6 +3817,30 @@
 			1 -- enable.
 			Default value is set via kernel config option.
 
+	sara.enabled=	[SARA] Disable or enable S.A.R.A. at boot time.
+			If disabled this way S.A.R.A. can't be enabled
+			again.
+			Format: { "0" | "1" }
+			See security/sara/Kconfig help text
+			0 -- disable.
+			1 -- enable.
+			Default value is set via kernel config option.
+
+	sara.wxprot_enabled= [SARA]
+			Disable or enable S.A.R.A. WX Protection
+			at boot time.
+			Format: { "0" | "1" }
+			See security/sara/Kconfig help text
+			0 -- disable.
+			1 -- enable.
+			Default value is set via kernel config option.
+
+	sara.wxprot_default_flags= [SARA]
+			Set S.A.R.A. WX Protection default flags.
+			Format: <integer>
+			See S.A.R.A. documentation.
+			Default value is set via kernel config option.
+
 	serialnumber	[BUGS=X86-32]
 
 	shapers=	[NET]
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
